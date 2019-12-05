# RealmCoder
JSON Encoder / Decoder for Realm objects

## TL;DR

A RealmCoder object allows you to easily decode a Realm object from a chunk of JSON data.  It also does the reverse, converting a Realm object to JSON data.  A key feature of RealmCoder is that it allows for incremental updates to the Realm.  Decoding a JSON block with partial data leaves the other attributes intact.

---

- [Motivation](#motivation)
- [Usage](#usage)
  - [The Simple Case](#the-simple-case)
  - [Key Mapping](#key-mapping)
  - [Ignored Attributes](#ignored-attributes)
  - [Raw JSON Substrings](#raw-json-substrings)
  - [REST Envelopes](#rest-envelopes)
- [License](#license)
- [About](#about)

---

## Motivation

Most iOS apps are clienst to some network server accessed via REST/JSON.  At Oak City Labs, we use Realm as a local database to cache info from the server, so the app can respond more quickly and still be useful offline.  (Sometimes we cache info for upload too.)  That means every app needs to take JSON data from the server and write it to the Realm database.  It is an excellent opportunity for a sharedy library.

The tricky bit is that we need to update our Realm objects incrementally.  Sometimes we don't get all the data about an object from the server.  Imagine a master-detail view for restaurants.  In the master view, you have a list of restaurants.  Tap on a restaurant and you drill down into the restaurant's detail page.  

We want the master list to be fast, so the server response includes summary info shown in the list, like the restaurant's name, but not the phone number.  When the info page loads, we request the detailed info include the phone number.  When you go back to the master list, you don't want a refresh of the summary data to clear the detailed info.

Realm makes it simple to do these incremental updates, if we're careful.  Realm can do a partial update on any object that has a primary key as long as we have a dictionary that _only includes the updated values_.

And that's what RealmCoder does.  By using the Realm schema for an object, we can match the attributes to the JSON keys and parse the data in a type safe way.  With the parsed data, we build an 'udpate' dictionary and apply it to the Realm database.  Everything happens at runtime and works automatically with any Realm object.  Using class variables on the model class, you can control things like name mapping, ignoring fields, etc.  If you have experience with Codable, RealmCoder should feel familar.

## Usage

### The Simple Case

You can create a RealmCoder object by passing a Realm object to the init function.

```swift
    let coder = RealmCoder(realm: realm)
```

RealmCoder works with an Realm object out of the box, with no special modifications to the object class.  This simple User class works automatically with RealmCoder.

```swift
    class User: Object {        
        @objc dynamic var objId: String = ""
        @objc dynamic var rank: Int = -1
    }
```

Decoding JSON data to a Realm object is a simple one line call, just like Codable.  The decode call returns an object already commited to the Realm.  If this class has a primary key and an object with the same primary key already exists, the decode method will incrementally update that object with the JSON data values.

```swift
    let user = try coder.decode(User.self, from: jsonData)
```

Encoding JSON is also simple.

```swift
    let jsonData = try coder.encode(user)
```

Note that these methods can throw.  Transactions with the underlying Realm can throw and those exceptions are propagated up.  Also the RealmCoder can run into issues when the Realm object's schema doesn't match the given data.  For example, an object defines an attribute an Int but the JSON value is a String.

### Key Mapping

Invariably there's a mismatch between object attribute names and JSON keys.  In RealmCoder, the default assumption is that the attr names and the keys match exactly.  If that's not the case, you can create your own mapping with a class variable called `realmCodableKeys`.  This String to String map enumerats the object's attribute name on the left and the JSON key names on the right.  Let's add a few fields to our `User` object.  

```swift
    class User: Object {
        @objc dynamic var objId: String = ""
        @objc dynamic var username: String = ""
        @objc dynamic var firstName: String = ""
        @objc dynamic var lastName: String = ""
    }
```

We'll need to translate between the camel case swift names and the snake case names in the JSON.  Also, let's map the JSON key of `id` to an attribute name of `objId`.  These are easy to define in a class attribute.  RealmCoder assumes any object attributes not listed here have the same name as their corresponding JSON key.

```swift
    override class var realmCodableKeys: [String: String] {
        return [
            "firstName": "first_name",
            "lastName": "last_name",
            "objId": "id"
        ]
    }
```

### Ignored Attributes

In some projects, you may have declared local attributes of a Realm object that shouldn't be sent to the server in the JSON.  You can specify these via a class variable called `realmCodableIgnoredAttributes` which returns an array of strings to ignore when encoding.

```swift
    override class var realmCodableIgnoredAttributes: [String] {
        return ["privateAttr1", "privateAttr2"]
    }
```

### Raw JSON Substrings

Occasionally, it might be useful to store raw JSON in an attribute.  You might store a complex (and possibly unknown) subtree for another component to consume.  You can specify those attributes with a `realmCodableRawJsonSubstrings` class attribute that returns an array of attribute names, just like 'ignored attributes'.  RealmCoder will store the JSON subtree for that key as the string value of that attribute.

```swift
    override class var realmCodableRawJsonSubstrings: [String] {
        return ["jsonSubTreeBlob"]
    }
```

### REST Envelopes

Many REST servers return objects contained in an 'envelope' to identify the type of object returned.  For example, a 'User' object might look like this in a JSON response:

```json
    {
      "user": {
        "email": "bats@superfriends.org",
        "first_name": "Bruce",
        "id": 3,
        "last_name": "Wayne",
      }
    }
```

In the same way, an array of objects often has a slightly different envelope.  A list of `User` objects might look like:

```json
    {
      "users": [
        {
          "email": "bats@superfriends.org",
          "first_name": "Bruce",
          "id": 3,
          "last_name": "Wayne",
        },
        {
          "email": "ww@superfriends.org",
          ...
        },
            {
          "email": "sups@superfriends.org",
          ...
        }
      ]
    }
```

Objects classes can express their envelope names to RealmCoder through class attributes. `realmObjectEnvelope` defines the envelope for a single object and `realmListEnvelope` is the envelope for a list of objects.

For the example JSON here, you can define the envelopes like this:

```swift
    override class var realmObjectEnvelope: String? {
        return "user"
    }
    
    override class var realmListEnvelope: String? {
        return "users"
    }
```

## License

[MIT licensed.](LICENSE.md)

## About

RealmCoder is a product of [Oak City Labs](https://oakcity.io).
