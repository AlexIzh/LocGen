# LocGen
Code generation for Localizable.strings file for Swift

This application generates constants with keys from Localizable.strings file. 
If you don't need to use `R.swift` or `SwiftGen` but just need to have constants from your Localizable.strings, you can try this app!

It will generate namespaces from your constants, so, for such strings as "GENERAL_BTN_OK" you will not have `.general_btn_ok` constant, but `General.Btn.ok`.

You can do the same with SwiftGen and templates. Probably it will be better for using, such as it can generates code for another resources as well.

# How it works

This app parses .strings file and separates keys by your separator (you can set up it with `-sc` flag, by default is `.`) and generates enums with the keys. 

For example:

`GENERAL_BTN_OK` -> `Localizations.General.Btn.ok`<br/>
`preferences.updates.last_update` -> `Localizations.Preferences.Updates.last_update`

Also, it will generates `localized` function for these constants. By default it just contains `NSLocalizedString(rawValue, comment: "")`, but you can override it as you want. 

Example of generated enums: 

```swift

enum Localizations: String, Localizable {
  case alert = "alert"//or "ALERT", if you prefer to use this style
  
  enum General {
    enum Btn: String, Localizable {
      case ok = "general.btn.ok"//or "GENERAL_BTN_OK"
      case yes = "general.btn.yes"//or "GENERAL_BTN_YES"
    }
    enum Error: String, Localizable {
      case title = "general.error.title"//or "GENERAL_ERROR_TITLE"
    }
  }
}

```

And you can use it as you want, you can use it for translating: `myLabel.text = Localizations.General.Btn.yes.localized`<br/>
Or just if you need to know key: `Localizations.General.Btn.yes.rawValue`

# Usage
This application contains a few flags, all of them are optional.<br/>
Example of usage: `locgen -i ./en.lproj/Localizable.strings -o Localizable.swift -cs \".\" -so ./Localizations+Strings.swift\n"`<br/>
Where:<br/>
`-i`: Input Localizable.strings file. Default value is Localizable.strings in current directory.<br/>
`-o`: Output file where generated strings should be placed. Default value is Localizable.swift in current directory.<br/>
`-cs`: String with characters which should be used for separating modules. Default is \".\"<br/>
`-so`: Support output file. IF this file exists already, this application will not replace it. This file contains default implementation for `localized` function. You can change it if you have another localization logic (for example, get translation from specific table). Default value is Localiztions+Strings.swift in current directory.

# Integrate to Xcode
You can add this app to directory with your project and add new script to `Build Phases` before `Compile Sources`.
`Shell: /bin/sh`<br/>
Example: `./locgen -i project/Resources/en.lproj/Localizable.strings -o project/Sources/View/Utils/Localizations.swift -so project/Sources/View/Utils/Localizations+String.swift`<br/>
So, your constants will be always updated and you will know, if some strings are changed.
