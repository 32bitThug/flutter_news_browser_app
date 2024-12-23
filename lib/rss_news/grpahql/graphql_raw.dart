class GraphQLRaw {
  static const getFeeds = r'''query GetFeeds {
  getFeeds {
    weight
    feed_url
    _id
    language
    category
    source
  }
}
''';

  static const getFeedsByCategory =
      r'''query GetFeedsByCategory($category: String) {
    getFeeds(filter: {
      category: $category,
    }) {
      weight
      feed_url
      _id
      language
      category
      source
    }
  }

''';
  static const createDevice =
      r'''mutation createDevice($id:String!,$name:String!,$gid:ID!,$pid:ID!){ 
  createDevice( deviceID: $id 
  deviceName: $name
  group_id: $gid
  Profile_id: $pid
) {
	_id
  deviceID
  deviceName
  group_id
  Profile_id
}
}

''';
  static const updateDevice = r'''mutation updateDevice($id:ID!,$name:String! ){
  updateDevice(id:$id,deviceName:$name){
    deviceName
  }
}
''';
  static const getDeviceById = r'''
  query getDeviceById($id:ID!) {
	getDeviceById(id: $id){
   _id
deviceID
deviceName
	}
}
  ''';
  static const pushLog = r'''
mutation createWebsiteUsageLogOrList ($domain: String,
$page_url: String,
$device_id: ID,
$category: String,) {

 createWebsiteUsageLogOrList(
  domain: $domain,
  page_url: $page_url
  device_id:$device_id
  category: $category
){
  Timestamp
}
}
  ''';
  static const childsActivities = r'''
query childsActivities($deviceId: String ) {
  getAllWebsiteUsageLogs(deviceID: $deviceId) {
  Timestamp
  page_url
    Device_id{
      deviceName
    }
    }
}
 ''';
  static const createSession = r'''
mutation CreateSession(
  $class: String!
  $subject: String!
  $chapter: String!
  $topics: [String!]!
  $subtopics: [String!]!
  $duration: Int!
) {
  createSession(
    class: $class
    subject: $subject
    chapter: $chapter
    topics: $topics
    subtopics: $subtopics
    duration: $duration
  ) {
    id 
  }
}


 ''';
  static const getBooks = r'''
  query getBooks {
  getBooks {
    id
    class
    subject
    board
  }
}
  ''';
  static const getDeviceBydeviceID = r'''
    query getDeviceBydeviceID($deviceID:String){
  getDeviceBydeviceID(deviceID:$deviceID){
    deviceName
    _id
  }
}
  
  ''';
  static const getPageAttributesByBookID =
      r'''query getPageAttributesByBookID($bookID: String!) {
  getPageAttributesByBookID(bookID: $bookID) {
    id
    pageNumber
    bookID
    text
    type
    order
  }
}
''';
}
