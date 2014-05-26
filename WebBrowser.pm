package WebBrowser;
use strict;
use LWP::UserAgent;
use Encode;

sub new {
    my $package = shift;
    $package = ref $package || $package;
    my $option = shift || {};
    my $this = bless $option, $package;
    $this->{'response'} = undef;
    $this->{'User-Agent'} ||= 'Kylin WebBrowser v1.0';
    $this->{'history'} ||= [];
    $this->{'charset'} ||= 'utf8';
    $this->{'cookie'} ||= {};
    $this->{'domain'} ||= '';
    $this->{'error'} ||= 0;
    $this->{'error_msg'} ||= '';
    $this->{'ua'} = LWP::UserAgent->new();
    $this->{'ua'}->requests_redirectable(['HEAD', 'GET', 'POST']);
    $this->{'ua'}->protocols_allowed(['http', 'https']);
    $this->{'ua'}->default_headers->header('User-Agent' => $this->{'User-Agent'});
    $this->{'ua'}->agent($this->{'User-Agent'});
    return $this;
}

sub browser {
    my $this = shift;
    return $this->{'ua'};
}

sub set_header {
    my $this = shift;
    my $domain = shift;
    $this->{'domain'} = $domain;
    my $ua = $this->browser;
    $ua->default_headers->header('Referer' => $this->{'history'}->[0]) if (scalar @{$this->{'history'}});
    my $cookie_str = [];
    foreach my $exist_cookie (keys %{$this->{'cookie'}}) {
        if ($domain =~ /$exist_cookie$/) {
            my $cookie = $this->{'cookie'}->{$exist_cookie};
            foreach my $cookie_name (keys %$cookie) {
                push (@$cookie_str, "$cookie_name=" . $cookie->{$cookie_name});
            }
        }
    }
    $ua->default_headers->header('Cookie' => join '; ', @$cookie_str) if (scalar @$cookie_str);
}

sub set_cookie {
    my $this = shift;
    my $cookies = shift;
    my $current_url = $this->{'history'}->[0];
    $current_url =~ /:\/\/([^\/]*)\//;
    my $current_domain = $1;
    foreach my $cookie (@$cookies) {
        my $fields = [split /;\s*/, $cookie];
        my ($name, $value, $domain) = ('', '', '');
        foreach my $field (@$fields) {
            $field =~ /^([^=]*)=(.*)$/;
            if ($1 eq 'expires') {
            } elsif ($1 eq 'path') {
            } elsif ($1 eq 'domain') {
                $domain = $2;
            } else {
                $name = $1;
                $value = $2;
            }
        }
        $domain = $current_domain if ($domain eq '');
        next if ($name eq '');
        $this->{'cookie'}->{$domain}->{$name} = $value;
    }
}

sub pre_action {
    my $this = shift;
    my $url = shift;
    if ($url !~ /\/\//) {
        if ($url =~ /^\//) {
            $url = "http://" . $this->{'domain'} . $url;
        } else {
            $this->{'history'}->[0] =~ /^(.*\/)[^\/]*$/;
            $url = $1 . $url;
        }
    }
    $url =~ /:\/\/([^\/]*)\//;
    $this->set_header($1);
    unshift @{$this->{'history'}}, $url;
    $url =~ /^(\w+):/;
    my $protocol = $1;
    if ($protocol ne 'http') {
        $this->{'error_msg'} = __PACKAGE__ . " do not support protocol $protocol.";
        $this->{'error'} = 1;
    }
    return $url;
}

sub post_action {
    my $this = shift;
    if ($this->{'response'}->previous) {
        $this->{'response'} = $this->{'response'}->previous;
    }
    if ($this->{'response'}->is_success) {
        $this->{'error'} = 0;
        $this->{'error_msg'} = '';
        my $set_cookie = [$this->{'response'}->header('set-cookie')];
        $this->set_cookie($set_cookie);
    } elsif ($this->{'response'}->is_redirect) {
        my $set_cookie = [$this->{'response'}->header('set-cookie')];
        $this->set_cookie($set_cookie);
        $this->visit($this->{'response'}->header('location'));
    } else {
        $this->{'error'} = 1;
        $this->{'error_msg'} = $this->{'response'}->status_line;
    }
}

sub visit {
    my $this = shift;
    my $url = shift;
    $url = $this->pre_action($url);
    $this->{'response'} = $this->browser->get($url);
    $this->post_action();
}

sub submit {
    my $this = shift;
    my $url = shift;
    $url = $this->pre_action($url);
    $this->{'response'} = $this->browser->post($url, @_);
    $this->post_action();
}

sub content {
    my $this = shift;
    return $this->{'error_msg'} if ($this->{'error'});
    return '' if (not $this->{'response'});
    my $content = $this->{'response'}->content();
    if ($content =~ /<meta.*?charset=([\w\d-]+).*?\/>/) {
        my $charset = $1;
        if ($charset and $charset ne $this->{'charset'}) {
            $content = Encode::decode($charset, $content);
            $content = Encode::encode($this->{'charset'}, $content);
        }
    }
    return $content;
}

1;
__END__
