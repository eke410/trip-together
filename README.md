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
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
