use inc::Module::Install;

RTx 'RT-Extension-DeactiveActionPref';
all_from 'lib/RT/Extension/DeactiveActionPref.pm';
readme_from 'lib/RT/Extension/DeactiveActionPref.pm';
license  'gplv2';

requires_rt '4.2.0';

sign;
WriteAll;
