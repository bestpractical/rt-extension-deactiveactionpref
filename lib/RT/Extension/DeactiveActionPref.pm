use strict;
use warnings;
package RT::Extension::DeactiveActionPref;

our $VERSION = '0.01';

use RT::Config;
$RT::Config::META{DeactiveAction} = {
    Section         => 'Ticket composition',      #loc
    Overridable     => 1,
    SortOrder       => 10,
    Widget          => '/Widgets/Form/Select',
    WidgetArguments => {
        Description => 'Action of links to change tickets to inactive status?', #loc
        Values      => [qw(Respond Comment)], #loc
    },
};

no warnings 'redefine';
use RT::Record::Role::Lifecycle;
use Scalar::Util 'blessed';
my $orig_lifecycle = \&RT::Queue::LifecycleObj;
*RT::Queue::LifecycleObj = sub {
    my $self = shift;
    my $res = $orig_lifecycle->($self);
    if ( blessed($self) && $self->id && $self->CurrentUser->id != RT->SystemUser->id ) {
        my $pref = $self->CurrentUser->Preferences(RT->System, {});
        if ( my $update_type = $pref->{DeactiveAction} ) {
            my @new_actions;
            for my $action ( @{ $res->{'data'}{'actions'} || [] } ) {
                if ( $res->IsInactive( $action->{to} ) ) {
                    push @new_actions, { %$action, update => $update_type };
                }
            }
            $res->{'data'}{'actions'} = \@new_actions;
        }
    }
    return $res;
};

=head1 NAME

RT-Extension-DeactiveActionPref - Deactive action user pref

=head1 DESCRIPTION

This extension allow user to specify the action(Respond or Comment) of links
that change a ticket to an inactive status, e.g. the default "Resolve" and
"Reject" links.

=head1 RT VERSION

Works with RT 4.2

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item Edit your F</opt/rt4/etc/RT_SiteConfig.pm>

    Plugin('RT::Extension::DeactiveActionPref');

or add C<RT::Extension::DeactiveActionPref> to your existing C<@Plugins> line.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 AUTHOR

sunnavy <sunnavy@bestpractical.com>

=head1 BUGS

All bugs should be reported via email to
L<bug-RT-Extension-DeactiveActionPref@rt.cpan.org|mailto:bug-RT-Extension-DeactiveActionPref@rt.cpan.org>
or via the web at
L<rt.cpan.org|http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-DeactiveActionPref>.

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2014 Best Practical Solutions, LLC.

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
