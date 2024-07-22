/// KWin script that acts as a companion to Posture Parrot, allowing it to work 
/// better with KDE in regards to things like Do Not Disturb, and user idle time.

/**
 * Prints a message to the console.
 * 
 * Other print methods are not showing up, so we are using console.info.
 * 
 * We are including a prefix to make it easier to find the messages.
 * 
 * Monitor output with:
 * $ journalctl -b -f | grep -i "posture-parrot-companion:"
 * 
 * @param {string} message The message to print.
 * @returns {void}
 */
function print(message) {
    console.info("posture-parrot-companion: " + message);
}

/**
 * Creates a debounced function that delays invoking `func` until after `wait` milliseconds have elapsed
 * since the last time the debounced function was invoked.
 *
 * @param {Function} func The function to debounce.
 * @param {number} wait The number of milliseconds to delay.
 * @returns {Function} Returns the new debounced function.
 */
function debounce(func, wait) {
    let timer = new QTimer();
    
    // Assuming QTimer() creates a KWin::ScriptTimer object and does not support setSingleShot.
    timer.timeout.connect(() => {
        func();
        timer.stop(); // Manually stop the timer to mimic single-shot behavior.
    });

    return function(...args) {
        if (timer.isActive) {
            timer.stop();
        }
        timer.start(wait); // Restart the timer for each call to the debounced function.
    };
}

/**
 * Debounce time to wait before notifying Posture Parrot of user activity.
 */
const DEBOUNCE_TIME = 30000; // 30 seconds

/**
 * The last time user activity was detected.
 */
let lastActivityTime = new Date().getTime();

/**
 * Flag to track if a notification has been sent in the current interval.
 */
let notificationSent = false;

/**
 * Updates the last activity time to the current time.
 */
function updateLastActivityTime() {
    lastActivityTime = new Date().getTime();
    notificationSent = false; // Reset the notification sent flag as there is new activity
}

/**
 * Called periodically to check if there has been user activity within the
 * DEBOUNCE_TIME interval and sends a notification if so.
 */
function periodicActivityCheck() {
    const currentTime = new Date().getTime();
    const isWithinDebounceTime = currentTime - lastActivityTime <= DEBOUNCE_TIME;
    const shouldNotifyPostureParrot = isWithinDebounceTime && !notificationSent;

    if (shouldNotifyPostureParrot) {
        notifyPostureParrot();
        notificationSent = true; // Mark that a notification has been sent
    }
}

/**
 * Sends a notification about user activity to Posture Parrot.
 */
function notifyPostureParrot() {
    // print("Sending user activity notification to Posture Parrot.");
    callDBus("codes.merritt.PostureParrot", "/", "codes.merritt.PostureParrot", "registerUserActivity");
}

/// To check user idle time, we get notified when the cursor position changes.
///
/// We will be able to then inform Posture Parrot that the user is active via 
/// the DBus interface.
workspace.cursorPosChanged.connect(updateLastActivityTime);

// Set up a timer to periodically check for user activity
let activityCheckTimer = new QTimer();
activityCheckTimer.timeout.connect(periodicActivityCheck);
activityCheckTimer.start(DEBOUNCE_TIME); // Check every DEBOUNCE_TIME interval
