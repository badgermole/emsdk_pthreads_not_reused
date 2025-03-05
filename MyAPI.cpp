#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <emscripten/threading.h>

// System includes
#include <pthread.h>
#include <string>


//========================================================================================

// Forward decl
void getVersionAsync(int promiseID);


extern "C" {
    void EMSCRIPTEN_KEEPALIVE settleAsyncPromise(int promiseId, int succeeded, const std::string* msg)
    {
        EM_ASM({
            let msgStr = UTF8ToString($2);
            settlePromise($0, $1, msgStr);
        }, promiseId, succeeded, msg->c_str());

        delete msg;
    }
}

/**
 * @return The version string
 */
std::string _getVersion()
{
    return "1.0.0";
}

//----------------------------------------------------------------------------------------
EMSCRIPTEN_BINDINGS(myApp)
{
    emscripten::function("getVersionAsync", &getVersionAsync);
    emscripten::function("_getVersion", &_getVersion);  // Just to test ouput
}

//========================================================================================
// Async task parameters
struct AsyncTaskParams
{
    AsyncTaskParams() = delete;
    AsyncTaskParams(int promiseID) : _promiseID(promiseID) {}

    int _promiseID;
};

//----------------------------------------------------------------------------------------
void* pt_getVersion(void* args)
{
    std::unique_ptr<AsyncTaskParams> pParams(static_cast<AsyncTaskParams*>(args));
    const auto& promiseID = pParams->_promiseID;

    std::string msg = "Ok";
    int succeeded = 1; // 0 ~ failure, 1 ~ success
    try
    {
        msg += std::string(": ") + _getVersion();  // forward to the base c++ method now that we set up the thread
    }
    catch(const std::exception& e)
    {
        msg = std::string("Error: ") + e.what();
        succeeded = 0;
    }

    // Call the function to settle the Promise on the main thread.  The last argument is a string pointer,
    // which will be deleted after this function exits in the settleAsyncPromise function.  That assures the
    // string is not deleted before the Promise is settled.
    std::string* pMsg = new std::string(msg);
    emscripten_async_run_in_main_runtime_thread(EM_FUNC_SIG_VIIP, settleAsyncPromise, promiseID, succeeded, pMsg);

    return nullptr;
}

//----------------------------------------------------------------------------------------
void getVersionAsync(int promiseID)
{
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

    // We have to dynamically allocate AsyncTaskParams so it doesn't go out of scope
    // before the thread has a chance to take ownership of it. The unique_ptr
    // inside the thread function will ensure its release
    auto* pParams = new AsyncTaskParams(promiseID);

    pthread_t id1;
    pthread_create(&id1, &attr, pt_getVersion, static_cast<void*>(pParams));
    pthread_attr_destroy(&attr);
}
