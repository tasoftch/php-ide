# Simple Debug-IDE
A simple and basic php IDE written in Objective-C<br>
To use just write
````objc
TADebugSession *session = [TADebugSession new];
TAConsole *console = [TAConsole new];
session.console = console;

// Define breakpoints if available
// [session setBreakpoints: ...];

// and start
NSTask *task = [NSTask new];
task.launchPath = @"/usr/local/bin/php";
task.arguments = @[ @"-i", @"/path/to/custom/php.ini", @"/path/to/script.php" ];
[session setupAndStartSessionWithPHPTask:task];

// and now you can control it by using
/*
- (IBAction)continueExecution:(id)sender;
- (IBAction)pauseExecutation:(id)sender;
- (IBAction)stopExecutation:(id)sender;

- (IBAction)stepOver:(id)sender;
- (IBAction)stepInto:(id)sender;
- (IBAction)stepOut:(id)sender;
*/
````
and use.<br>
It is up to you to configure the php binary with a debugger.<br>
The TADebugSession tries to connect for 2 seconds, and if the debugger does not respond<br>
it cancels the debug session.
