> Disclaimer: While there is a reproduction for bugs 1 and 2, I am still not sure if there are other factors at play.

This repo contains reproduction and documentation for three seperate BlueJ bugs:
1. [Issues with UTF-8 support on import / export (on Windows).](#bug-1-bluej-jar-import-in-specific-cases-and-export-lacks-proper-utf-8-support)
2. [Issues with importing non-BlueJ projects (on Linux).](#almost-bug-2-maybe-its-windows-or-just-more-bugs-bluej-hangs-converting-non-bluej-projects-seemingly-randomly-but-with-consistency-where-it-matters-particularly-on-linux)
3. [Issues with BlueJ seemingly randomly deleting files.](#bug-3-bluej-likes-to-delete-files-ctrlz-issue--unknown)

And I've included [Independent Testing](#independent-testing) at the end.

# Bug 1: BlueJ Jar import (in specific cases) and export lacks proper UTF-8 support.

I was adding Unicode to my project and when running it in BlueJ I noticed the characters were mangled, I believe that the issue has to do with BlueJ not using the correct encoding on Windows. I eventually figured out how to reproduce it correctly.

## Observations

**Note**: the following was tested on and does not occur on Linux.

Unicode emoji appearing garbled in BlueJ. (4 hex digits when looking at hex dump)

| ![image](https://user-images.githubusercontent.com/38285861/143617804-29a4e8b0-92b1-4f20-97a4-371ce007cdd2.png) | ![image](https://user-images.githubusercontent.com/38285861/143617843-4a9aa7bd-6d35-4438-be10-2c3bca406b59.png) |
|:-:|:-:|
| As seen in BlueJ | As seen in Visual Studio Code |

After pasting `😳` through emoji picker, we find that: (1 hex digit when looking at hex dump)

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

## Reproduction

Must be on Windows.

This can be reproduced in a few simple steps:
1. Create a new BlueJ project on Windows
2. Create a new class `Main.java` and copy the following contents:

   ```java
   import java.io.FileWriter;

   public class Main {
       public static void main(String[] args) {
           try {
               var writer = new FileWriter("output.txt");
               writer.write("🤔");
               writer.close();
           } catch (Exception e) {
               e.printStackTrace();
           }
       }
   }
   ```
3. Invoke the main function from BlueJ.
4. Inspect `output.txt` using a code editor that supports Unicode to verify that there is indeed an emoji.
5. Select `Project -> Create Jar File`.
6. Export this to a new folder.
7. Export again but this time without BlueJ project files included.
8. Run `java -jar <your new file>.jar` on both files and each time, verify `output.txt` does not show a valid emoji.

Continued reproduction steps for import:
1. Take the JARs from before.
2. Either:
   - (Recommended) Copy the project folder to a Linux machine and export from there, afterwards copy the JAR file back.

     One of the times you export, do not include project files.
   - Download my two exported JARs [with project files](https://github.com/insertish/bluej-bug-demo/raw/master/Reproduction%20Steps/with_project_files.jar) and [without project files](https://github.com/insertish/bluej-bug-demo/raw/master/Reproduction%20Steps/without_project_files.jar).
     
     These files were exported as described in the step above.
3. Select `Project -> Open ZIP/JAR...`.
4. Select the JAR file without project files.
5. Edit `Main.java` and notice that the emoji is garbled.
   
   You should see something such as:
   
   ![image](https://user-images.githubusercontent.com/38285861/143625850-b1922eef-302f-4334-8a3a-39295c0a3060.png)
6. Select the JAR file with project files.
7. Edit `Main.java` and notice that the emoji is not garbled.

Note: I then tried to take `without_project_files.jar` back on Linux and found a completely separate issue detailed below.

## Conclusion

JARs exported from BlueJ on Windows appear to not be encoded properly.

JARs imported into BlueJ on Windows that were exported by BlueJ that specifically excluded project files and originate from another platform such as Linux or generated in another way are not decoded properly.

# (Almost) Bug 2: ~~Maybe it's Windows? Or just more bugs.~~ BlueJ hangs converting non-BlueJ projects seemingly randomly but with consistency where it matters (particularly on Linux).

**Read this first!** I encountered this bug for a brief period until further restarts, but I chose to keep the information here anyways since.

While I was testing this, someone mentioned to me about `chcp 65001`, which in fact led me to discover yet another bug.

> **Disclaimer**: This is probably something to do with the way I'm building the jar... on Linux but not Windows that's causing BlueJ to choke but at the same time that doesn't really make sense since the procedure is the same. Although I do a final test in reverse at the end.

I enabled the [Unicode UTF-8 beta (for non-Unicode programs) in Windows using this StackOverflow guide](https://stackoverflow.com/questions/57131654/using-utf-8-encoding-chcp-65001-in-command-prompt-windows-powershell-window) (I didn't realise at the time this was for "non-Unicode" programs but the fact that I caused an issue with it was interesting enough to keep it here), which led me to find:

1. Using the Windows exported jar on Windows, I got the same result, with mangled emoji.
2. Using the Linux exported jar on Windows caused BlueJ to eternally hang.
   
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

### Verifying reproducability

**Note**: this was superseded by new information and the reproduction below.

And just as quickly as this bug appeared, it disappeared. Toggling the setting above twice (and restarting twice) caused the issue to disappear completely. This is also as unreliable to test as this random bug that I get that warns me that package declarations are wrong.

## Reproduction

You must be on Linux (may also occur on Windows, haven't tested).

1. Create a new BlueJ project.
2. Create `Main.java` and populate it with:

   ```java
   public class Main {
       public static void main(String[] args) {
           System.out.println("test");
       }
   }
   ```

3. Export this project as a JAR file, **without the project files**.
4. Close BlueJ and open this JAR file in BlueJ (or use [the one I built earlier](https://github.com/insertish/bluej-bug-demo/raw/master/Reproduction%20Steps/bug2_export.jar)) or otherwise do this through the context menus.
5. Find BlueJ is no longer doing anything but infinitely loading.

   ![image](https://user-images.githubusercontent.com/38285861/143627062-4603b087-008a-4e48-b28a-a9840ae7c9f2.png)

6. Look in the debug log to find the error as below:

   ```
   ====
   BlueJ run started: Fri Nov 26 20:16:38 GMT 2021
   BlueJ version 5.0.2
   Java version 11.0.12
   JavaFX version 11.0.10-internal+0-2021-01-10-174716
   Virtual machine: OpenJDK 64-Bit Server VM 11.0.12+7 (Oracle Corporation)
   Running on: Linux 5.13.13-arch1-1 (amd64)
   Java Home: /usr/lib/jvm/java-11-openjdk
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
           at com.sun.glass.ui.gtk.GtkApplication._runLoop(Native Method)
           at com.sun.glass.ui.gtk.GtkApplication.lambda$runLoop$11(GtkApplication.java:277)
           at java.base/java.lang.Thread.run(Thread.java:829)
   ```

# Bug 3: BlueJ likes to delete files (ctrl+z issue / unknown)

This is a really bad bug report but I thought it should be mentioned since it's happened to 3 different people I know, although I haven't been able to reproduce it, it appears to happen in one of two ways:
1. Undo history is cleared or otherwise not kept track of properly:
   - `i think i did ctrl + a, ctrl + c then delete, just cause its something i so when iw anna reset my clipboard`
   - in conversation later, other person also confirmed similar story: `same XD i was trying to delete the line i am on`
2. BlueJ does not seem to recover from sudden close, one person after abruptly having to turn their computer off found the class they were working on to be completely empty.

Here's an example from scenario (1.):
![image](https://user-images.githubusercontent.com/38285861/143622889-10e7a7f5-cc06-418c-8a05-703ef754ab2d.png)

## Independent Testing

I forwarded the built jars on to others and found the following:

| Independent Windows Test<br/>(bug 1: w/ no project files jar) | Running Jar to find invalid output.txt<br/>(bug 1: export issues, either jar) | Independent Linux Test<br/>(bug 2: w/ no project files jar) |
|:-:|:-:|:-:|
|✅<br/>Matches my results.|✅<br/>Matches my results.|❌<br/>Does not match my results|
|![image](https://user-images.githubusercontent.com/38285861/143630256-e7493b3f-de96-449c-ac9b-65c970f1fb08.png)|![image](https://user-images.githubusercontent.com/38285861/143630891-9de6bc1c-2e8e-4700-82bf-4acd772b8e50.png)|![image](https://user-images.githubusercontent.com/38285861/143638144-f67e3a74-f8ea-4f16-baae-50b97c5b8e59.png)|
