# Bug: BlueJ lacks UTF-8 support(?) on Windows

I was adding Unicode to my project and when running it in BlueJ I noticed the characters were mangled, I believe that the issue has to do with BlueJ not using the correct encoding on Windows.

## Observations

**Note**: the following was tested on and does not occur on Linux.

Unicode emoji appearing garbled in BlueJ. (4 hex digits when looking at hex dump)

| ![image](https://user-images.githubusercontent.com/38285861/143617804-29a4e8b0-92b1-4f20-97a4-371ce007cdd2.png) | ![image](https://user-images.githubusercontent.com/38285861/143617843-4a9aa7bd-6d35-4438-be10-2c3bca406b59.png) |
|:-:|:-:|
| As seen in BlueJ | As seen in Visual Studio Code |

Observed after pasting `😳` through emoji picker. (1 hex digit when looking at hex dump)

| ![image](https://user-images.githubusercontent.com/38285861/143617871-9a43b4ce-1cff-4308-9e2a-71a618e7c910.png) | ![image](https://user-images.githubusercontent.com/38285861/143617864-748c0bc4-8eec-4a34-a99f-8522a3be1e0a.png) |
|:-:|:-:|
| As seen in BlueJ | As seen in Visual Studio Code |

Clearly, on Windows specifically, BlueJ appears to be using the wrong encoding.

## Tests

This series of tests did the following steps:
1. Export a new jar for BlueJ, with the original encoding and source.
2. Export a jar from BlueJ after importing (1.) and then immediately re-exporting it.
   
   This is just a sanity check to ensure that it is a valid BlueJ jar.
3. Edit `App.java` and replace the garbled emoji by pasting `😳` then export the jar.

Linux .jar export comparisons

![image](https://user-images.githubusercontent.com/38285861/143616446-48559ce8-4e02-4aaa-ab9b-8df5f276b9e4.png)

Windows .jar export comparisons

![image](https://user-images.githubusercontent.com/38285861/143618268-aa1a5601-8f6f-4d46-9430-77392362a73b.png)

Linux .jar export being unpacked on Windows (also hit an unrelated error)

![image](https://user-images.githubusercontent.com/38285861/143618210-c3c658d6-134f-4116-add5-0d0d201a7ec4.png)

## Maybe it's Windows? Or just more bugs.

While I was testing this, someone mentioned to me about `chcp 65001`, which in fact led me to discover yet another bug.

> **Disclaimer**: This is probably something to do with the way I'm building the jar... on Linux but not Windows that's causing BlueJ to choke but at the same time that doesn't really make sense since the procedure is the same. Although I do a final test in reverse at the end.

I enabled the [Unicode UTF-8 beta in Windows using this StackOverflow guide](https://stackoverflow.com/questions/57131654/using-utf-8-encoding-chcp-65001-in-command-prompt-windows-powershell-window), which led me to find:

1. Using the Windows exported jar on Windows, I got the same result, with mangled emoji.
2. Using the Linux exported jar ([download bluej_out.jar](https://github.com/insertish/bluej-bug-demo/raw/master/Linux%20Exports/bluej_out.jar)) on Windows caused BlueJ to eternally hang.
   
   As seen in the picture below:
   
   ![image](https://user-images.githubusercontent.com/38285861/143619477-6f109b86-ee68-4cee-977d-fd61dd993768.png)

   Upon checking the debug log I found this error:
   
   ```
   ====
   BlueJ run started: Fri Nov 26 18:23:14 GMT 2021
   BlueJ version 5.0.2
   Java version 11.0.10
   JavaFX version 11.0.2+1
   Virtual machine: OpenJDK 64-Bit Server VM 11.0.10+9 (AdoptOpenJDK)
   Running on: Windows 10 10.0 (amd64)
   Java Home: C:\Program Files\BlueJ\jdk
   ----
   Opening project: C:\Users\paul\Documents\Coursework\cleanbluej\demo\Windows Exports\danger
   1637950996619: Listening for JDWP connection on address: javadebug
   Connected to debug VM via dt_shmem transport...
   Communication with debug VM fully established.
   ====

   ====
   BlueJ run started: Fri Nov 26 18:23:29 GMT 2021
   BlueJ version 5.0.2
   Java version 11.0.10
   JavaFX version 11.0.2+1
   Virtual machine: OpenJDK 64-Bit Server VM 11.0.10+9 (AdoptOpenJDK)
   Running on: Windows 10 10.0 (amd64)
   Java Home: C:\Program Files\BlueJ\jdk
   ----
   Exception in thread "JavaFX Application Thread" java.lang.NullPointerException
      at bluej.utility.JavaNames.getPrefix(JavaNames.java:163)
      at bluej.pkgmgr.Import.convertNonBlueJ(Import.java:100)
      at bluej.pkgmgr.PkgMgrFrame.openArchive(PkgMgrFrame.java:1710)
      at bluej.pkgmgr.PkgMgrFrame.doOpen(PkgMgrFrame.java:889)
      at bluej.BlueJGuiHandler.tryOpen(BlueJGuiHandler.java:50)
      at bluej.Main.processArgs(Main.java:202)
      at bluej.Main.lambda$new$1(Main.java:170)
      at com.sun.javafx.application.PlatformImpl.lambda$runLater$10(PlatformImpl.java:428)
      at java.base/java.security.AccessController.doPrivileged(Native Method)
      at com.sun.javafx.application.PlatformImpl.lambda$runLater$11(PlatformImpl.java:427)
      at com.sun.glass.ui.InvokeLaterDispatcher$Future.run(InvokeLaterDispatcher.java:96)
      at com.sun.glass.ui.win.WinApplication._runLoop(Native Method)
      at com.sun.glass.ui.win.WinApplication.lambda$runLoop$3(WinApplication.java:174)
      at java.base/java.lang.Thread.run(Thread.java:834)
   ```
3. Using the BlueJ exported jar from Linux on Windows worked just fine.

### Ok how about doing it in reverse?

This time, I took that existing BlueJ project (from a working copy with mangled characters, i.e. the original but successfully imported), exported it while under this Windows beta mode and then restarted to see what would happen when I imported that project, I didn't expect much and it just worked as intended so I guess it was more just to see how if there would be any issue.
