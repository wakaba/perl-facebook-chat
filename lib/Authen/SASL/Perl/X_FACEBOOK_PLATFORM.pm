package Authen::SASL::Perl::X_FACEBOOK_PLATFORM;
use strict;
use warnings;
our $VERSION = '1.0';
use base qw(Authen::SASL::Perl);

# Spec: <https://developers.facebook.com/docs/chat>.

my %secflags = (
  noplaintext => 1,
  noanonymous => 1,
);

sub _order { 10 }
sub _secflags {
  shift;
  scalar grep { $secflags{$_} } @_;
}

sub mechanism { 'X-FACEBOOK-PLATFORM' }

sub client_start {
  my $self = shift;
  return '';
}

sub client_step {
  my ($self, $challenge) = @_;
  # $challenge = 'version=1&method=auth.xmpp_login&nonce=0899B8...';

  my %challenge = (
      # map { percent_decode_c $_ }
      map { split /=/, $_, 2 } split /&/, $challenge
  );

  my $api_key = $self->_call('api_key');
  my $access_token = $self->_call('access_token');
  
  my %response = (
      v => '1.0',
      method => $challenge{method},
      nonce => $challenge{nonce},
      api_key => $api_key,
      access_token => $access_token,
      call_id => 0,
  );
  return join '&', map {
      # percent_encode_c
      $_ . 
      '=' . 
      # percent_encode_c
      $response{$_}
  } keys %response;
}

=head1 NAME

Authen::SASL::Perl::X_FACEBOOK_PLATFORM - X-FACEBOOK-PLATFORM SASL mechanism for Authen::SASL::Perl

=head1 SEE ALSO

Facebook Chat API <https://developers.facebook.com/docs/chat>.

L<Authen::SASL>.

=head1 AUTHOR

Wakaba (id:wakabatan) <wakabatan@hatena.ne.jp>.

=head1 LICENSE

Copyright 2011 Hatena <http://www.hatena.com/>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
