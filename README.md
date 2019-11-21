# RealmCoder
JSON Encoder / Decoder for Realm objects

## Description

A RealmCoder objects allows you to easily decode a Realm object from a give chunk of JSON data.  It also does the reverse, given a Realm object, it can encode the corresponsing JSON representation.  A key feature of RealmCoder is that it allows for incremental updates to the Realm.  Decoding a JSON block with partial data for an object only overwrites the fields in the JSON.  Missing fields are not altered.

RealmCoder works by inspected the schema for a Realm object type and using that metadata to map the attribute names and types to the JSON data.

## Usage

### The Simple Case

You can create a RealmCoder object by passing a Realm object to the init function.

    let coder = RealmCoder(realm: realm)

RealmCoder works with an Realm object out of the box, with no special modifications to the object class.  This simple User class works automatically with RealmCoder.

    class User: Object {        
        @objc dynamic var objId: String = ""
        @objc dynamic var rank: Int = -1
    }

Decoding JSON data to a Realm object is a simple one line call, just like Codable.  The decode call returns an object already commited to the Realm.  If this class has a primary key and an object with the same primary key already exists, the decode method will incrementally update that object with the JSON data values.

    let user = try coder.decode(User.self, from: jsonData)

Encoding JSON is also simple.

    let jsonData = try coder.encode(user)

Note that these methods can throw.  Transactions with the underlying Realm can throw and those exceptions are propagated up.  Also the RealmCoder can run into issues when the Realm object's schema doesn't match the given data.  For example, an object defines an attribute an Int but the JSON value is a String.

### Key Mapping

Invariably there's a mismatch between object attribute names and JSON keys.  In RealmCoder, the default assumption is that the attr names and the keys match exactly.  If that's not the case, you can create your own mapping with a class variable called `realmCodableKeys`.  This String to String map enumerats the object's attribute name on the left and the JSON key names on the right.  Let's add a few fields to our `User` object.  

    class User: Object {
        @objc dynamic var objId: String = ""
        @objc dynamic var username: String = ""
        @objc dynamic var firstName: String = ""
        @objc dynamic var lastName: String = ""
    }

We'll need to translate between the camel case swift names and the snake case names in the JSON.  Also, let's map the JSON key of `id` to an attribute name of `objId`.  These are easy to define in a class attribute.  RealmCoder assumes any object attributes not listed here have the same name as their corresponding JSON key.

    override class var realmCodableKeys: [String: String] {
        return [
            "firstName": "first_name",
            "lastName": "last_name",
            "objId": "id"
        ]
    }

### Ignored Attributes

In some projects, you may have declared local attributes of a Realm object that shouldn't be sent to the server in the JSON.  You can specify these via a class variable called `realmCodableIgnoredAttributes` which returns an array of strings to ignore when encoding.

    override class var realmCodableIgnoredAttributes: [String] {
        return ["privateAttr1", "privateAttr2"]
    }

### Raw JSON Substrings

Occasionally, it might be useful to store raw JSON in an attribute.  You might store a complex (and possibly unknown) subtree for another component to consume.  You can specify those attributes with a `realmCodableRawJsonSubstrings` class attribute that returns an array of attribute names, just like 'ignored attributes'.  RealmCoder will store the JSON subtree for that key as the string value of that attribute.

    override class var realmCodableRawJsonSubstrings: [String] {
        return ["jsonSubTreeBlob"]
    }

### REST Envelops

Many REST servers return objects contained in an 'envelope' to identify the type of object returned.  For example, a 'User' object might look like this in a JSON response:

    {
      "user": {
        "email": "bats@superfriends.org",
        "first_name": "Bruce",
        "id": 3,
        "last_name": "Wayne",
      }
    }

In the same way, an array of objects often has a slightly different envelope.  A list of `User` objects might look like:

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
    {

Objects classes can express their envelope names to RealmCoder through class attributes. `realmObjectEnvelope` defines the envelope for a single object and `realmListEnvelope` is the envelope for a list of objects.

For the example JSON here, you can define the envelopes like this:

    override class var realmObjectEnvelope: String? {
        return "user"
    }
    
    override class var realmListEnvelope: String? {
        return "users"
    }

