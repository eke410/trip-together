# Trip Together

## Demo
Narrated Demo:
https://user-images.githubusercontent.com/32204411/128400505-ebd554aa-32ea-4657-9599-592b51eb3f76.mp4

Unnarrated Demo:
https://user-images.githubusercontent.com/32204411/129102295-576903ac-cde5-4603-aa37-39b6e7462502.mp4

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
TripTogether is a social travel app designed to help users plan trips with friends. Users can form groups with other people, schedule visits to tourist attractions and restaurants, and see shared group itineraries. The app will warn users if they attempt to schedule an event at a time where another group member already has plans.

### App Evaluation
- **Category:** Travel & social
- **Mobile:** Convenient for users to bring on trips. Uses maps, location, & camera.
- **Story:** Facilitates easy group communication for families or friends to plan trips and travel together. 
- **Market:** Anyone who wants to travel.
- **Habit:** Users would just use the apps before and during trips to plan in advance and to stay on schedule.
- **Scope:** MVP would just include group creation, event booking, event validation. Lots of avenues for expansion - visual map itinerary, sorting events and groups, wishlists, notifications, etc. 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* user log in
* group creation
* group itinerary
* explore event section
* event booking
* event validation

**Optional Nice-to-have Stories**

* friends feature
* group messaging
* event notifications
* maps to look up nearby places
* split bills in group / IOU feature
* trip photo album or memories log
* user profile with past trips
* discover section where people can share and view public trip itineraries & templates

### 2. Screen Archetypes

* Login / Register 
    * User can log in or sign up.
* Stream 
    * User can scroll through relevant tourist attractions & restaurants.
* Detail 
    * User can book events & click on their pages for more detail. 
* Creation
    * User can create a trip, create a group.
    * User can add items to their itinerary.
* Profile
    * User can view their identity.
* Settings 
    * User can configure app options, e.g. notification settings.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home tab - personal calendar, itinerary, bookings
* Explore tab - search for bookings
* Group tab - everything group related

**Flow Navigation** (Screen to Screen)

* Login / Register
  => Home tab
* Stream
  => Details screen
* Detail
  => Back to Stream
* Creation
  => Back to whichever tab the page is in. (e.g. create a group -> group tab, create an event -> home tab)
* Profile
  => None
* Settings
  => None

## Wireframes
<img src="https://i.imgur.com/z6brBSa.jpg">


### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 

### Models

#### User 
| Property  | Type         | Description          |
| --------- | ------------ |:-------------------- |
| objectId  | String       | unique id for user   |
| firstName | String       | first name of user   |
| lastName  | String       | last name of user    |
| username  | String       | username             |
| password  | String       | password             |
| photo     | PFFileObject | user profile picture |


#### Group
| Property  | Type             | Description                |
| --------- | ---------------- | -------------------------- |
| objectId  | String           | unique id for group        |
| name      | String           | name of group              |
| users     | Array (of Users) | users in group             |
| location  | String           | specifies location of trip |
| startDate | DateTime         | start date of trip         |
| endDate   | DateTime         | end date of trip           |
| photo     | PFFileObject     | group picture              |

#### Event
| Property         | Type     | Description                                     |
| ---------------- | -------- | ----------------------------------------------- |
| objectId         | String   | unique id for event                             |
| yelpId           | String   | yelp id for event                               |
| name             | String   | name of event                                   |
| placeDescription | String   | description of event                            |
| group            | Group    | group that event is booked for                  |
| startTime        | NSDate   | start time of event                             |
| endTime          | NSDate   | end time of event                               |
| location         | String   | specifies location of event                     |
| latitude         | String   | latitude of event                               |
| longitude        | String   | longitude of event                              |
| imageURLString   | String   | URL to Yelp image of event                      |
| rating           | NSString | Yelp rating out of 5 for event                  |
| yelpURL          | String   | link to yelp page of event                      |
| phone            | String   | phone number of event                           |
| categories       | Array    | list of categories that describe event          |
| priceLevel       | String   | priciness from $ to $$$$ of event               |
| reviewCount      | String   | number of reviews on yelp                       |
| photoURLStrings  | Array    | array of yelp photos of event                   |
| websiteURL       | String   | link to website of event                        |
| type             | String   | type of event - either attraction or restaurant |

### Networking
#### List of network requests by screen

 - Home Screen
     - (Read/GET) Query all events which user is signed up for*
 - Explore Screen
     - none
 - Book Event Page
     - (Read/GET) Query groups which user is a part of*
     - (Create/POST) Create new Event for a group
 - Group Screen
     - (Read/GET) Query groups which user is a part of*
     - (Delete) Delete group / remove user from group
 - Group Details Page
     - (Read/GET) Query events which group is signed up for
     - (Delete) Delete event group is signed up for
 - Create a Group Page
     - (Create/POST) Create a new group
     - (Read/GET) Query all users

#### Code Snippets for Network Requests
##### (Create/POST) Create a new group
```
PFObject *newGroup = [PFObject objectWithClassName:@"Group"];
// TODO: set properties (e.g. newGroup[@"name"] = "Weekend in NYC")
[newGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
  if (succeeded) {
    // The object has been saved.
  } else {
    // There was a problem, check error.description
  }
}];
```

##### (Create/POST) Create new Event for a group
```
PFObject *newEvent = [PFObject objectWithClassName:@"Event"];
// TODO: set properties (e.g. newEvent[@"group"] = group)
[newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
  if (succeeded) {
    // The object has been saved.
  } else {
    // There was a problem, check error.description
  }
}];
```

##### (Read/GET) Query all events which group is signed up for
```
PFQuery *query = [PFQuery queryWithClassName:@"Event"];
[query orderByDescending:@"startTime"];
[query whereKey:@"group" equalTo:group];
[query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
    if (events != nil) {
        print("Successfully retrieved \(events.count) events.")
        // TODO: Do something with events
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}];
```

##### (Read/GET) Query all users
```
PFQuery *query = [PFQuery queryWithClassName:@"User"];
[query orderByDescending:@"firstName"];
[query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
    if (users != nil) {
        print("Successfully retrieved \(events.count) events.")
        // TODO: Do something with events
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}];
```

##### (Delete) Delete group / event
```
// TODO: set objectArray to include either group or event that needs to be deleted
[PFObject deleteAllInBackground:objectArray block:^(BOOL succeeded, NSError * _Nullable error) {
    if (succeeded) {
        // The array of objects was successfully deleted.
    } else {
        // There was an error. Check the errors localizedDescription.
    }
}];
```


#### [OPTIONAL] Existing API Endpoints

##### Yelp
Base URL  - https://www.yelp.com/developers/documentation/v3/event_search

##### Google Calendar
Base URL - https://developers.google.com/workspace/guides/ios
