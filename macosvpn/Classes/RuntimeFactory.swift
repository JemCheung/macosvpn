/*
 Copyright (c) 2019 halo. https://github.com/halo/macosvpn
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Darwin
import Moderator

extension Runtime {
  enum Factory {
    static func make(_ arguments: [String]) -> Runtime {
      let parser = Moderator()
      
      let commandName = parser.add(Argument<String>.singleArgument(name: ""))
      let versionFlag = parser.add(Argument<Bool>.option("version", "v"))
      let helpFlag = parser.add(Argument<Bool>.option("help", "h"))
      let forceFlag = parser.add(Argument<Bool>.option("force", "o"))
      
      do {
        try parser.parse(arguments, strict: false)
      } catch {
        Log.error(String(describing: error))
        exit(VPNExitCode.InvalidArguments)
      }
      
      let runtime = Runtime()
      
      // Highest precedence when requesting help, bail our immediately
      if helpFlag.value {
        runtime.command = .help
        return runtime
      }
      
      if versionFlag.value {
        runtime.command = .version
        return runtime
      }
      
      guard let commandNameValue = commandName.value else {
        Log.error("You must specify a command.")
        return runtime
      }

      guard let command = Command(rawValue: commandNameValue) else {
        Log.error("Unknown command: \(commandNameValue)")
        return runtime
      }
      
      runtime.command = command
      runtime.forceRequested = forceFlag.value

      return runtime
    }
  }
}