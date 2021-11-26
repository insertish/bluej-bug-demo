# Bug: BlueJ lacks UTF-8 support(?) on Windows

I was adding Unicode to my project and when running it in BlueJ I noticed the characters were mangled, in fact it was reading each 

## Observations

Unicode emoji appearing garbled in BlueJ. (4 )

![image](https://user-images.githubusercontent.com/38285861/143617804-29a4e8b0-92b1-4f20-97a4-371ce007cdd2.png)
![image](https://user-images.githubusercontent.com/38285861/143617843-4a9aa7bd-6d35-4438-be10-2c3bca406b59.png)

Observed after pasting 😳 through emoji picker.

![image](https://user-images.githubusercontent.com/38285861/143617871-9a43b4ce-1cff-4308-9e2a-71a618e7c910.png)
![image](https://user-images.githubusercontent.com/38285861/143617864-748c0bc4-8eec-4a34-a99f-8522a3be1e0a.png)

## Tests

Linux .jar export comparisons

![image](https://user-images.githubusercontent.com/38285861/143616446-48559ce8-4e02-4aaa-ab9b-8df5f276b9e4.png)

Windows .jar export comparisons

![image](https://user-images.githubusercontent.com/38285861/143618268-aa1a5601-8f6f-4d46-9430-77392362a73b.png)

Linux .jar export being unpacked on Windows (also hit an unrelated error)

![image](https://user-images.githubusercontent.com/38285861/143618210-c3c658d6-134f-4116-add5-0d0d201a7ec4.png)

## Maybe it's Windows? Or just more bugs.

While I was testing this, someone mentioned to me about `chcp 65001`, which in fact led me to discover yet another bug.

I enabled the [Unicode UTF-8 beta in Windows using this StackOverflow guide](https://stackoverflow.com/questions/57131654/using-utf-8-encoding-chcp-65001-in-command-prompt-windows-powershell-window), which led me to find:

1. Using the Windows exported jar on Windows, I got the same result, with mangled emoji.
2. Using the Linux exported jar on Windows caused BlueJ to crash eternally hang.
   As seen in the picture below:
   
   <!- paste image here ->
