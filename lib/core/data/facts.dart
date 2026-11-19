class VoyagerFacts {
  static const String appName = 'Aurum Signal';
  static const String subtitle = 'A tribute to Voyager 1 · One Light-Day';
  static const String repositoryUrl =
      'https://github.com/your-username/aurum-signal';

  static final DateTime milestoneUtc = DateTime.utc(2026, 11, 18, 10, 16, 7);
  static const double milestoneKm = 25902068356;
  static const double milestoneMiles = 16094799096;
  static const double milestoneAu = 173.14;
  static const double auKm = 149597870.7;
  static const double lightSpeedKmPerSecond = 299792.458;
  static const double minutesPerAu = 8.3167;
  static const double oneWayHours = 24;

  static const String launchDate = '5 September 1977';
  static const String timeSinceLaunch = '49 years, 2 months, 11 days';
  static const String jupiterDate = '5 March 1979';
  static const String saturnDate = '12 November 1980';
  static const String saturnDistance = 'about 126,000 km';
  static const String paleBlueDotDate = '14 February 1990';
  static const String paleBlueDotDistance = 'about 6 billion km';
  static const String heliopauseDate = '25 August 2012';
  static const String voyagerTwoMilestone = '2035';

  static const String callSign = 'VGR';
  static const String voyagerWord = 'VOYAGER';

  static const String milestoneSentence =
      'Voyager 1 reached one light-day from Earth.';
  static const String symbolicNote =
      'Crossing one light-day changes nothing about the spacecraft itself. '
      'It is a marker we choose to notice.';

  static double lightSecondsForKm(double km) => km / lightSpeedKmPerSecond;
  static double auForKm(double km) => km / auKm;
  static double lightMinutesForAu(double au) => au * minutesPerAu;
}
