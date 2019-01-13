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
  `phone` varchar(16) NULL,
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

INSERT INTO `news` (`id`, `title`, `content`, `news_date`, `created`, `modified`) VALUES
(1, 'Repas du club', 'Repas de club avec tartiflettre géante', '2018-05-30 23:17:12', '2018-06-01 00:35:07', NULL),
(2, 'Réunion de dèbut d\'année', 'Réunion de dèbut d\'année pour oganiser les roulages', '2018-05-30 23:31:44', '2018-06-01 00:35:07', NULL),
(3, 'Réunion pour organisation foire au 2 roues', 'Réunion pour organisation foire au 2 roues qui auralieu de 21 mars 2020', '2018-06-01 00:01:36', '2018-06-01 00:35:07', NULL);

INSERT INTO `members` (`id`, `first_name`, `last_name`, `email`, `phone`, `bike`, `created`, `modified`) VALUES
(1, 'John', 'Doe', 'john.doe@mail.fr', '+33608080808', 'Honda CBR 600 RR 2007', '2018-01-30 00:00:00', '2018-07-01 09:30:54', NULL),
(2, 'Jenna', 'Jonhnson', 'jenna.jonhnson@mail.com', NULL, 'Kawasaki ZX6R 636 2015', '2018-02-30 00:00:00', '2018-07-01 09:37:12', NULL);

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