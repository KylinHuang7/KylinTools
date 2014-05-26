package IDCard;
use strict;
use Date::Calc qw//;

use constant TRUE  => 1;
use constant FALSE => 0;

sub new {
    my ($package, $id_card) = @_;
    $package = ref $package || $package;
    my $this = bless {}, $package;
    $this->{'ID_CARD'} = $id_card;
    return $this if ($this->check_valid());
    return undef;
}

sub check_valid {
    my $this = shift;
    if ($this->type() == 15) {
        return $this->check_15_valid();
    } elsif ($this->type() == 18) {
        return $this->check_18_valid();
    } else {
        return FALSE;
    }
}

sub check_15_valid {
    my $this = shift;
    return FALSE if ($this->{'ID_CARD'} !~ /^\d{15}$/);
    $this->{'LOCATION_CODE'} = substr $this->{'ID_CARD'}, 0, 6;
    $this->{'BIRTH_CODE'}    = '19' . substr $this->{'ID_CARD'}, 6, 6;
    $this->{'SERIAL_CODE'}   = substr $this->{'ID_CARD'}, 12, 3;
    return FALSE if (!$this->check_location());
    return FALSE if (!$this->check_birth());
    return FALSE if (!$this->check_serial());
    return TRUE;
}

sub check_18_valid {
    my $this = shift;
    return FALSE if ($this->{'ID_CARD'} !~ /^\d{17}[\dX]$/);
    $this->{'LOCATION_CODE'} = substr $this->{'ID_CARD'}, 0, 6;
    $this->{'BIRTH_CODE'}    = substr $this->{'ID_CARD'}, 6, 8;
    $this->{'SERIAL_CODE'}   = substr $this->{'ID_CARD'}, 14, 3;
    $this->{'CHECK_CODE'}    = uc substr $this->{'ID_CARD'}, 17, 1;
    return FALSE if (!$this->check_location());
    return FALSE if (!$this->check_birth());
    return FALSE if (!$this->check_serial());
    return FALSE if (!$this->check_last());
    return TRUE;
}

sub check_location {
    my $this = shift;
    $this->{'PROVINCE_CODE'} = substr $this->{'LOCATION_CODE'}, 0, 2;
    $this->{'CITY_CODE'}     = substr $this->{'LOCATION_CODE'}, 2, 2;
    $this->{'VILLAGE_CODE'}  = substr $this->{'LOCATION_CODE'}, 4, 2;
    return FALSE if (!defined(PROVINCE_LIMIT()->{$this->{'PROVINCE_CODE'}}));
    return TRUE  if (ref PROVINCE_LIMIT()->{$this->{'PROVINCE_CODE'}} ne 'ARRAY');
    return FALSE if ($this->{'CITY_CODE'} eq '00');
    return FALSE if ($this->{'CITY_CODE'} > PROVINCE_LIMIT()->{$this->{'PROVINCE_CODE'}}->[0] and $this->{'CITY_CODE'} <= 20);
    return FALSE if ($this->{'CITY_CODE'} > PROVINCE_LIMIT()->{$this->{'PROVINCE_CODE'}}->[1] and $this->{'CITY_CODE'} <= 50);
    return FALSE if ($this->{'CITY_CODE'} > PROVINCE_LIMIT()->{$this->{'PROVINCE_CODE'}}->[2] and $this->{'CITY_CODE'} <= 70);
    return FALSE if ($this->{'CITY_CODE'} > 70 and $this->{'CITY_CODE'} != 90);
    return FALSE if ($this->{'VILLAGE_CODE'} eq '00');
    return TRUE;
}

sub check_birth {
    my $this = shift;
    $this->{'BIRTH_YEAR'}  = substr $this->{'BIRTH_CODE'}, 0, 4;
    $this->{'BIRTH_MONTH'} = substr $this->{'BIRTH_CODE'}, 4, 2;
    $this->{'BIRTH_DATE'}  = substr $this->{'BIRTH_CODE'}, 6, 2;
    return TRUE if (Date::Calc::check_date($this->{'BIRTH_YEAR'}, $this->{'BIRTH_MONTH'}, $this->{'BIRTH_DATE'}));
    return FALSE;
}

sub check_serial {
    my $this = shift;
    $this->{'GENDER'} = $this->{'SERIAL_CODE'} % 2;
    return TRUE;
}

sub check_last {
    my $this = shift;
    return TRUE if ($this->type() != 18);
    my $wi = [];
    for (my $i = 0; $i < 17; ++$i) {
        $wi->[$i] = (2 ** (17 - $i)) % 11;
    }
    my $sum = 0;
    for (my $i = 0; $i < 17; ++$i) {
        $sum += substr($this->{'ID_CARD'}, $i, 1) * $wi->[$i];
    }
    my $index = $sum % 11;
    my $checkCode = "10X98765432";
    return TRUE if (substr($checkCode, $index, 1) eq $this->{'CHECK_CODE'});
    return FALSE;
}

sub type {
    my $this = shift;
    return length $this->{'ID_CARD'};
}

sub id_card {
    my $this = shift;
    return $this->{'ID_CARD'};
}

sub location {
    my $this = shift;
    return '';
}

sub birthday {
    my $this = shift;
    return "$this->{'BIRTH_YEAR'}-$this->{'BIRTH_MONTH'}-$this->{'BIRTH_DATE'}";
}

sub gender {
    my $this = shift;
    return $this->{'GENDER'};
}

use constant PROVINCE_LIMIT => {
    '11' => [ 2, 50, 70],
    '12' => [ 2, 50, 70],
    '13' => [11, 50, 70],
    '14' => [11, 50, 70],
    '15' => [ 9, 29, 70],
    '21' => [14, 50, 70],
    '22' => [ 8, 24, 70],
    '23' => [12, 27, 70],
    '31' => [ 2, 50, 70],
    '32' => [13, 50, 70],
    '33' => [11, 50, 70],
    '34' => [18, 50, 70],
    '35' => [ 9, 50, 70],
    '36' => [11, 50, 70],
    '37' => [17, 50, 70],
    '41' => [17, 50, 70],
    '42' => [13, 28, 70],
    '43' => [13, 31, 70],
    '44' => [20, 50, 53],
    '45' => [14, 50, 70],
    '46' => [ 2, 50, 70],
    '50' => [ 2, 50, 70],
    '51' => [20, 34, 70],
    '52' => [ 4, 27, 70],
    '53' => [ 9, 34, 70],
    '54' => [ 1, 26, 70],
    '61' => [10, 50, 70],
    '62' => [12, 30, 70],
    '63' => [ 1, 28, 70],
    '64' => [ 5, 50, 70],
    '65' => [ 2, 43, 70],
    '71' => 1,
    '81' => 1,
    '82' => 1,
};

1;

__END__
