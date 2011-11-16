package AnyEvent::XMPP::ForceFacebookSASLSupport;
use strict;
use warnings;
our $VERSION = '1.0';
use Exporter::Lite;

our @EXPORT = qw(enable_facebook_sasl_support_for_anyevent_xmpp);

our $APIKey;
our $AccessToken;

sub enable_facebook_sasl_support_for_anyevent_xmpp (&) {
    no warnings 'redefine';
    my $code = shift;
    require AnyEvent::XMPP::Writer;
    require Authen::SASL;
    my $orig_send_sasl_auth = \&AnyEvent::XMPP::Writer::send_sasl_auth;
    my $orig_authen_sasl_new = \&Authen::SASL::new;
    local *AnyEvent::XMPP::Writer::send_sasl_auth = sub {
        local *Authen::SASL::new = sub {
            my ($class, %args) = @_;
            if ($args{callback}) {
                $args{callback}->{api_key} = $APIKey;
                $args{callback}->{access_token} = $AccessToken;
            }
            return $orig_authen_sasl_new->(@_);
        };
        return $orig_send_sasl_auth->(@_);
    };
    $code->();
}

=head1 NAME

AnyEvent::XMPP::ForceFacebookSASLSupport - A hack to enable Facebook Chat support for AnyEvent::XMPP

=head1 SYNOPSIS

  use AnyEvent::XMPP::ForceFacebookSASLSupport;
  $AnyEvent::XMPP::ForceFacebookSASLSupport::APIKey = $api_key;
  $AnyEvent::XMPP::ForceFacebookSASLSupport::AccessToken = $access_token;

  enable_facebook_sasl_support_for_anyevent_xmpp {
    AnyEvent::XMPP::...
  };

=head1 AUTHOR

Wakaba (id:wakabatan) <wakabatan@hatena.ne.jp>.

=head1 LICENSE

Copyright 2011 Hatena <http://www.hatena.com/>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
