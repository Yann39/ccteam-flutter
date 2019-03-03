/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

CREATE TABLE IF NOT EXISTS `news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `content` text NOT NULL,
  `news_date` datetime NOT NULL,
  `created` timestamp NOT NULL,
  `modified` timestamp NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(64) NOT NULL,
  `last_name` varchar(64) NOT NULL,
  `email` varchar(128) NOT NULL,
  `password` varchar(255) NOT NULL,
  `active` boolean NOT NULL DEFAULT FALSE,
  `admin` boolean NOT NULL DEFAULT FALSE,
  `phone` varchar(13) NULL,
  `bike` varchar(64) NULL,
  `registration_date` datetime NOT NULL,
  `created` timestamp NOT NULL,
  `modified` timestamp NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `tracks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `description` text NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(64) NOT NULL,
  `description` text NULL,
  `link` text NOT NULL,
  `created` timestamp NOT NULL,
  `modified` timestamp NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text NULL,
  `event_date` datetime NOT NULL,
  `track_id` int NOT NULL,
  `organizer` varchar(64) NOT NULL,
  `price` decimal(6,2) NOT NULL,
  `created` timestamp NOT NULL,
  `modified` timestamp NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_track FOREIGN KEY (track_id) REFERENCES tracks(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `events_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `member_id` int NOT NULL,
  `created` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES events(id),
  CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES members(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

INSERT INTO `news` (`id`, `title`, `content`, `news_date`, `created`, `modified`) VALUES
(1, 'Repas du club', 'Repas de club avec tartiflettre géante', '2018-05-30 23:17:12', '2018-06-01 00:35:07', NULL),
(2, 'Réunion de dèbut d\'année', 'Réunion de dèbut d\'année pour oganiser les roulages', '2018-05-30 23:31:44', '2018-06-01 00:35:07', NULL),
(3, 'Réunion pour organisation foire au 2 roues', 'Réunion pour organisation foire au 2 roues qui auralieu de 21 mars 2020', '2018-06-01 00:01:36', '2018-06-01 00:35:07', NULL);

INSERT INTO `members` (`id`, `first_name`, `last_name`, `email`, `password`, `active`, `admin`, `phone`, `bike`, `created`, `modified`) VALUES
(1, 'John', 'Doe', 'john.doe@mail.fr', '1234', 1, 0, '+33608080808', 'Honda CBR 600 RR 2007', '2018-01-30 00:00:00', '2018-07-01 09:30:54', NULL),
(2, 'Jenna', 'Jonhnson', 'jenna.jonhnson@mail.com', '1234', 0, 0, NULL, 'Kawasaki ZX6R 636 2015', '2018-02-30 00:00:00', '2018-07-01 09:37:12', NULL);

INSERT INTO `tracks` (`id`, `name`, `description`) VALUES
(1, 'Bresse', ''),
(2, 'Dijon-Prenois', ''),
(3, 'Magny-Cours', ''),
(4, 'Bourbonnais', ''),
(5, 'Vaison', ''),
(6, 'Lédenon', '');

INSERT INTO `events` (`id`, `title`, `description`, `event_date`, `track_id`, `organizer`, `price`, `created`, `modified`) VALUES
(1, 'Roulage', '', '2018-07-12 00:00:00', 2, 'ActivBike', 189, '2018-06-01 09:35:07', NULL),
(2, 'Roulage', '', '2018-08-02 00:00:00', 5, 'ActivBike', 90, '2018-02-08 14:30:29', NULL),
(3, 'Roulage', '', '2018-08-28 00:00:00', 1, 'Team Blatz', 125, '2018-04-20 17:14:27', NULL);

INSERT INTO `photos` (`id`, `title`, `description`, `link`, `created`, `modified`) VALUES
(1, 'Lorenzo', 'Lorenzo qui célèbre sa victoire', 'http://example.com/uploads/2018/06/IMG_1.jpg', '2018-09-12 10:33:19', NULL),
(2, 'Marc Màrquez', 'Marc Màrquez dans le 1er virage', 'http://example.com/uploads/2018/06/IMG_2.jpg', '2018-02-08 14:30:29', NULL),
(3, 'Johann Zarco', 'Johann Zarco', 'http://example.com/uploads/2018/06/IMG_3.jpg', '2018-04-20 17:14:27', NULL),
(4, 'Enea Bastianini', 'Enea Bastianini', 'http://example.com/uploads/2018/06/IMG_4.jpg', '2018-11-21 14:09:04', NULL),
(5, 'Enea Bastianini', 'Enea Bastianini', 'http://example.com/uploads/2018/06/IMG_5.jpg', '2018-04-06 11:55:21', NULL);

INSERT INTO `events_members` (`id`, `event_id`, `member_id`, `created`) VALUES
(1, 3, 2, '2018-06-01 09:35:07'),
(2, 1, 1, '2018-02-08 14:30:29'),
(3, 3, 1, '2018-04-20 17:14:27'),
(4, 2, 1, '2017-11-18 10:42:55');