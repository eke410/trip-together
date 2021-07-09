# Trip Together

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Social Travel organizer where users can plan trips with friends and view an organized visual itinerary. Users can book lodging, transportation, and events straight from the app. Users can also form a group with fellow travelers, which creates a joint calendar and itinerary for their trip.

### App Evaluation
- **Category:** Travel (+ social as scope expands)
- **Mobile:** Convenient for users to bring on trips. Uses maps, location, & possibly camera, real-time messaging as scope expands. 
- **Story:** Facilitates easy group communication for families or friends to plan trips and travel together. 
- **Market:** Anyone who wants to travel.
- **Habit:** Users would just use the apps before and during trips to plan in advance and to stay on schedule.
- **Scope:** MVP would just include bookings, group creation, and an organized calendar / itinerary. Lots of avenues for expansion - including messaging, notifications, split bils feature, user profiles with past trips, discover section, photo albums and logs for trips, etc. 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* user log in
* lodging, transportation, and event booking 
* create a group trip feature
* joint calendar / itinerary feature

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
    * User can scroll through relevant lodging, transportation, and event options.
* Detail 
    * User can book lodging, transportation, events & click on specific pages for more details.
* Creation
    * User can create a trip, create a group.
    * User can add items to their calendar / itinerary.
* Profile
    * User can view their identity (and past trips as extra feature)
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
<img src="https://scontent-bos3-1.xx.fbcdn.net/v/t1.15752-9/211070028_341136337392533_7048821287326844631_n.jpg?_nc_cat=110&ccb=1-3&_nc_sid=ae9488&_nc_ohc=SU98cAuCXaEAX8RDnR5&_nc_ht=scontent-bos3-1.xx&_nc_rmd=260&oh=9713584be5a493aa54c75df8509376ce&oe=60EB8440" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 

### Models

#### User - either PFUser or connect to Google login 
(will be hashed out more once I look into Google authentication)
| Property              | Type   | Description                                                     |
| --------------------- | ------ |:--------------------------------------------------------------- |
| objectId              | String | unique id for user                                              |
| firstName             | String | first name of user                                              |
| lastName              | String | last name of user                                               |
| username              | String | username                                                        |
| password              | String | password                                                        |
| profileImageURLString | String | URL path for user's profile pic                                 |
| GoogleAccount*        | TBD    | some identifier for the Google account associated with the user |
| groups*               | Array  | groups user is a part of                                        |


#### Group
| Property  | Type              | Description                |
| --------- | ----------------- | -------------------------- |
| objectId  | String            | unique id for group        |
| name      | String            | name of group              |
| users     | Array (of Users)  | users in group             |
| location  | String            | specifies location of trip |
| startDate | DateTime          | start date of trip         |
| endDate   | DateTime          | end date of trip           |
| events*   | Array (of Events) | events added to group      |

#### Event
| Property           | Type            | Description                             |
| ------------------ | --------------- | --------------------------------------- |
| objectId           | String          | unique id for event                     |
| name               | String          | name of event                           |
| description        | String          | description of event                    |
| group              | String or Group | group(id?) that event was signed up for |
| eventSiteURLString | String          | URL to event site                       |
| ticketsURLString   | String          | URL to buy tickets for event            |
| location           | String          | specifies location of event             |
| latitude           | String          | latitude of event                       |
| longitude          | String          | longitude of event                      |
| startTime          | DateTime        | start time of event                     |
| endTime            | DateTime        | end time of event                       |
| imageURL           | String          | URL to Yelp image of event              |

(more properties from [Yelp's event endpoint](https://www.yelp.com/developers/documentation/v3/event) that can be added if extra time)

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
