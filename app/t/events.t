use t::common;
use parent qw(Test::Class);

use Play::Events;

sub setup :Tests(setup) {
    Dancer::session->destroy;
    reset_db();
}

sub event_perl_api :Tests {
    my $events = Play::Events->new;
    $events->add({ blah => 5, boo => 6 });
    $events->add({ foo => 'bar' });

    cmp_deeply(
        $events->list,
        [
            { foo => 'bar', ts => re('^\d+$'), _id => re('^\S+$') }, # last in, first out
            { blah => 5, boo => 6, ts => re('^\d+$'), _id => re('^\S+$') },
        ]
    );
}

sub events_limit :Tests {
    my $events = Play::Events->new;
    $events->add({ name => "e$_" }) for (1 .. 200);

    is scalar @{ $events->list }, 100;
}

sub events_http_api :Tests {
    my $events = Play::Events->new;
    $events->add({ blah => 5 });
    $events->add({ blah => 6 });

    my $list = http_json GET => '/api/event';
    cmp_deeply
        $list,
        [
            { blah => 6, _id => re('^\S+$'), ts => re('^\d+$') },
            { blah => 5, _id => re('^\S+$'), ts => re('^\d+$') },
        ]
}

sub atom :Tests {
    # add-user event
    http_json GET => '/api/fakeuser/Frodo';

    # add-quest event
    my $add_result = http_json POST => '/api/quest', {
        user => 'Frodo',
        name => 'Destroy the Ring',
        status => 'open',
    };

    my $response = dancer_response GET => '/api/event/atom';
    is $response->status, 200;

    diag ($response->content);

    like $response->content, qr/Frodo joins Play Perl/;
}

__PACKAGE__->new->runtests;
