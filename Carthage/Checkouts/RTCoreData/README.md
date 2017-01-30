
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


## Installation
RTCoreData is designed to be installed using Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate RTCoreData into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
git "git@github.com:ryanphillipthomas/RTCoreData.git" ~> 1.0
```

Run `carthage` to build the framework and drag the built `RTCoreData.framework` into your Xcode project.

## Requirements

| RTCoreData Version | Minimum iOS Target |
|:--------------------:|:---------------------------:|
| 1.x | iOS 9 |

---

## Usage

### Creating the main context

To create the main context you call `createMainContext(modelStoreName: String, bundles: [NSBundle]?)` This function sets up the Core Data stack and returns the main context.

### Creating ManagedObjects

Managed objects should be subclassed from `ManagedObject` and should conform to the `ManagedObjectType` protocol. The `ManagedObjectType` protocol requireds the implementation of `entityName` variable. You can also implement the `defaultSortDescriptors` variable if you wish.

```swift 
extension User: ManagedObjectType {
    public static var entityName: String {
        return "User"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
}
```

### Inserting a Managed Object

Once a `ManagedObject` object conforms to the `ManagedObjectType` protocol inserting it into the the mananged object context is done by simply calling `insertObject()`

```swift 
let moc:NSManagedObjectContext = ...
let newUser: User = moc.insertObject()
```

### Saving Objects

To save changes to the context you can use `saveOrRollback()` but incapsulating the changes in the `performChanges(block:()->())` block is preferred. This function attempt to save all the changes asynchronously. 


### Fetching Objects

To fetch a single `ManagedObject` object that conforms to the `ManagedObjectType` protocol, use `findOrFetchInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self?`

You can also use `findOrCreateInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate, configure: Self -> ()) -> Self` to find or create an object if it doesn't exist.

To fetch more than one object, use `fetchInContext(context: NSManagedObjectContext, @noescape configurationBlock: NSFetchRequest -> () = { _ in }) -> [Self]`



