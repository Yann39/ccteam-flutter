# Chachatte team

Flutter mobile application for the "Chachatte team" motorcycle racing club

# Screenshots

![Login page screenshot](doc/login.png "Login page")
![Home page screenshot](doc/news.png "Home page")
![Events page screenshot](doc/events.png "Events page")
![Members page screenshot](doc/members.png "Members page")
![Tracks page screenshot](doc/tracks.png "Tracks page")
![Gallery page screenshot](doc/gallery.png "Gallery page")

# Usage

You must be an authorized member to use the application.

# Dependencies 

The following packages have been used :
 
- intl: for internationalization and localization
- http: Future-based library for making HTTP requests
- cupertino_icons: Cupertino icons fonts
- cached_network_image: to load and cache network images
- url_launcher: to open URLs (used for the mailto action)
- shared_preferences: to be able to use shared preferences
- provider : state management pattern
- logging : for logging

# Features

The application offers the following features :
- Register and login members
- Display member profiles
- Create circuits
- Create events on circuits and identify participants
- Display event calendar
- Add and display photos

# Technical details

PHP API, uses PDO

The application is connected to an external MariaDB database via REST web services.

Passwords are hashed using PHP default hashing algorithm (which uses bcrypt as I'm using PHP 7).

Only user e-mail is kept in shared preferences

# License

[General Public License (GPL) v3](https://www.gnu.org/licenses/gpl-3.0.en.html)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.
    
You should have received a copy of the GNU General Public License along with this program.  If not,
see <http://www.gnu.org/licenses/>.

