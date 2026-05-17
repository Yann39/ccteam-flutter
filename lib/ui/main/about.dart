/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Static "About" page reachable from the top-right quick-action menu.
///
/// Visual language: same blue gradient background as the rest of the
/// authenticated app, content laid out as a vertical list of light
/// cards. Each card has a colored icon, a short title and a paragraph
/// of body text — same idiom as the track / member detail pages so the
/// page feels familiar.
///
/// Content is intentionally short — one paragraph per topic, no walls
/// of text. The page is stateless, no provider plumbing, so it's safe
/// to push as a regular named route.
class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  /// One card row: a leading colored icon in a soft circle, a bold
  /// title on top and a body paragraph underneath. Used both for the
  /// "purpose" and "privacy" sections — keeps the visual rhythm.
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget body,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: CustomDecorations.cardLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: 0.15)),
            child: Icon(icon, color: iconColor, size: 22.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6.0),
                DefaultTextStyle.merge(
                  style: TextStyle(color: Colors.black.withAlpha(204), fontSize: 13.5, height: 1.4),
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One bullet for the "features" list: small dot + label.
  Widget _featureBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 16.0, color: Colors.blue[700]),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.black.withAlpha(204), fontSize: 13.5, height: 1.3)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppString.aboutTitle)),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 24.0),
            children: <Widget>[
              // Hero: logo + app name + version + tagline
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    'images/app_logos/ccteam_logo_vertical_red_white.svg',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: Text(
                  AppString.applicationTitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 2.0),
              Center(
                child: Text(
                  'v${AppString.applicationVersion}',
                  style: TextStyle(
                    color: Colors.black.withAlpha(140),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    AppString.applicationTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withAlpha(180),
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Purpose
              _buildSectionCard(
                icon: Icons.info_outline,
                iconColor: Colors.blue[700]!,
                title: AppString.aboutPurposeTitle,
                body: Text(AppString.aboutPurposeBody),
              ),

              // Features (bullet list)
              _buildSectionCard(
                icon: Icons.star_border,
                iconColor: Colors.amber[800]!,
                title: AppString.aboutFeaturesTitle,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _featureBullet(Icons.event, AppString.aboutFeatureCalendar),
                    _featureBullet(Icons.group, AppString.aboutFeatureMembers),
                    _featureBullet(Icons.place, AppString.aboutFeatureTracks),
                    _featureBullet(Icons.timer, AppString.aboutFeatureChronos),
                    _featureBullet(Icons.photo_album, AppString.aboutFeatureGalleries),
                    _featureBullet(Icons.article_outlined, AppString.aboutFeatureNews),
                  ],
                ),
              ),

              // Privacy
              _buildSectionCard(
                icon: Icons.shield_outlined,
                iconColor: Colors.green[700]!,
                title: AppString.aboutPrivacyTitle,
                body: Text(AppString.aboutPrivacyBody),
              ),

              // Open source
              _buildSectionCard(
                icon: Icons.code,
                iconColor: Colors.deepPurple[400]!,
                title: AppString.aboutOpenSourceTitle,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppString.aboutOpenSourceBody),
                    const SizedBox(height: 8.0),
                    // Flutter ships a built-in license browser — surfacing it
                    // satisfies the GPL "show users the licenses of bundled
                    // dependencies" expectation without any extra plumbing.
                    InkWell(
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: AppString.applicationTitle,
                        applicationVersion: AppString.applicationVersion,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.description_outlined, size: 16.0, color: Colors.deepPurple[400]),
                            const SizedBox(width: 6.0),
                            Text(
                              AppString.aboutThirdPartyLicenses,
                              style: TextStyle(
                                color: Colors.deepPurple[400],
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.deepPurple[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // Copyright footer
              Center(
                child: Text(
                  AppString.aboutCopyright,
                  style: TextStyle(color: Colors.black.withAlpha(130), fontSize: 12.0, letterSpacing: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
