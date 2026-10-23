# 1.0.0

2026-05-25

- Initial release

# 1.0.1

2026-05-26

- Display a "Member" badge in the user account page when the user is a member
- Display the number of items next to each list in the member, event and track detail pages
- Display the bike manufacturer logo instead of the bike icon when associating a motorcycle with an event
- Allow selecting dates from 01.01.2000 to now in all the date pickers (+1 year for the news date picker)
- Fixed news content being hidden behind the phone's bottom app bar
- Fixed track icon not centered horizontally in the event detail page
- Fixed error snackbar popping repeatedly after a role change

# 1.0.2

2026-06-04

- Only use the date for lap times, no need for date and time
- Validate that the passcode always contains 6 digits on creation, update and confirmation
- Automatically use the version from pubspec.yaml in the Android build and in the About page
- Reduced news detail font size
- Fixed date card displaying the same day twice in the event detail page
- Fixed news UI not updated after an update
- Fixed spelling mistake for "galerie" in French

# 1.1.0

2026-06-12

- Added push notifications for news and events, with notification preferences
- Added ability to add an event to the system calendar
- Added dedicated page for bikes, with the list of lap times and some statistics
- Allow members to set the visibility of their lap records
- Allow selecting dates in the future when creating an event, and removed the date validation when creating a news
- Added icons to the main action menu
- Fixed news sorting after adding a news
- Fixed event detail data not up to date after an event update

# 1.1.1

2026-07-06

- Handle guest accounts (can view all content but in read-only)
- Added possibility to filter the member lap record list by track, bike and weather
- Display a warning in the notifications settings page if the notifications permission is not granted
- Standardized font size in animated headers when they are collapsed
- Do not display a detail row in the lap record page if its content is empty

# 1.2.0

2026-07-25

- Link the authentication to the user device
- Added possibility to list trusted devices and revoke a device
- Allow to enter the lap record details in the track creation form
- Allow to filter the member lap record list by visibility
- Reworked lap record detail header to include the rider name
- Display the bike manufacturer logo and the track icon in the bike and track dropdown lists
- Added Paul Ricard circuit cover and icons
- Fixed number of participants not up to date in the event card after registering to the event
- Upgraded Dart and Flutter to latest stable versions
- Upgraded Gradle and related plugins to latest stable versions

# 1.2.1

2026-08-10

- Handle multiple versions of a track (different layout, reverse mode, etc.)
- Added possibility to view who liked a news from the news detail page
- Added links to GitHub repositories in the About page

# 1.2.2

2026-08-22

- Only display members and guests by default in the member list
- Added Jura Sud circuit cover and icons
- Fixed Paul Ricard 5.8 km icon mapping

# 1.2.3

2026-09-02

- Added possibility to define event sessions and let participants mark the ones they actually attended
- Added possibility to create a new event organizer from the dropdown list in the event form
- Reworked UI of the lap record list page
- Display translated labels instead of codes in the conditions dropdown lists
- Fixed conditions dropdown list value selection when editing a lap time
- Fixed icon of the 5.8 km version of the Paul Ricard circuit overflowing from its container

# 1.3.0

2026-10-17

- Added ability to manage motorcycle maintenance plans
- Added ability to enter the motorcycle equipment details
- Added motorcycle odometer reading in the motorcycle detail page
- Added possibility to export the maintenance history and the detail of a bike as PDF documents
- Added estimated driving time of a motorcycle in the statistics
- Added possibility to add a comment for an event participation
- Defer loading of data in the member detail page
- Fixed bike statistics not updated after modifying an event
- Upgraded Dart, Flutter and dependencies

# 1.3.1

2026-10-23

- Added option to reorder the motorbike equipment list
- Organized motorcycle data into tabs
- Added line chart in the bike statistics to show the evolution of kilometers over time
- Improved motorcycle maintenance history page UI
- Fixed motorcycle maintenance history timeline horizontal alignment
- Fixed last modifier of a news item wrongly read from the creator

# 1.3.2

in progress

- Fixed app stuck on the loading page at startup
- Fixed push notifications not working
- Fixed title of the news form showing "Ajouter une actualité" when editing a news item
- Display an error and go to the login page if an unexpected error occurs at startup, instead of loading forever
