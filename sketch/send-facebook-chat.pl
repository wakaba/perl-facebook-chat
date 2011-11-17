use strict;
use warnings;
use lib qw(../lib);
use AnyEvent::XMPP::Client;
use AnyEvent;

my $from_id = q<...username...@chat.facebook.com>;
my $to_id = q<-...userid...@chat.facebook.com>;
my $api_key = '...app id...';
my $access_token = '...oauth access token...';
my $message = 'Hello, World!';

use AnyEvent::XMPP::ForceFacebookSASLSupport;
$AnyEvent::XMPP::ForceFacebookSASLSupport::APIKey = $api_key;
$AnyEvent::XMPP::ForceFacebookSASLSupport::AccessToken = $access_token;

my $j = AnyEvent->condvar;
my $cl = AnyEvent::XMPP::Client->new(debug => 1);

my $w;
enable_facebook_sasl_support_for_anyevent_xmpp {
    $cl->reg_cb(
        connected => sub {
            warn "Connected\n";
            $cl->get_account($from_id)->connection->reg_cb(send_buffer_empty => sub {
                $cl->disconnect;
                $j->send;
            });
            $cl->send_message($message, $to_id, $from_id, 'chat');
        },
        error => sub {
            my ($account, $error) = @_;
            warn "Error: $account $error\n";
        },
        connect_error => sub {
            my ($account, $reason) = @_;
            warn "Connect error $account $reason\n";
        },
    );
    $cl->add_account($from_id, 'dummy');
    $cl->start;
    $j->recv;
};
