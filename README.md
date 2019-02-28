# Chachatte team

Flutter mobile application for the "Chachatte team" motorcycle racing club

# Screenshots

![Homepage screenshot](doc/news.png "Homepage")
![Events screenshot](doc/events.png "Events")
![Members screenshot](doc/members.png "Members")
![Gallery screenshot](doc/gallery.png "Gallery")

# Usage

You must be an authorized member to use the application.

# Dependencies 

The following packages have been used :
 
- intl: 0.15.7 : for internationalization and localization
- http: 0.12.0 : Future-based library for making HTTP requests
- cupertino_icons: ^0.1.0 : Cupertino icons fonts
- cached_network_image: ^0.5.1 : to load and cache network images
- url_launcher: ^5.0.0 : to open URLs (used for the mailto action)

# Features

The application offers the following features :
- Register club members
- Display member profiles
- Create circuits
- Create events on circuits and identify participants
- Display event calendar
- Add and display photos

# Technical details

The application is connected to an external MariaDB database via REST web services.

Passwords are hashed using PHP default hashing algorithm (which uses bcrypt as I'm using PHP 7).

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

