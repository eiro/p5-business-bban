package Business::myIBAN;

use Modern::Perl;

##
# Package helper to compute an IBAN key, generate and format an IBAN from a BBAN
# and the country code.
#
# @author Vincent Lucas
##

##
# Converts alpha characters into digit, following IBAN rules: replaces each
# alpha character with 2 digits A = 10, B = 11, ..., Z = 35.
#
# @param bban A string to convert into the IBAN digit representation.
#
# @return A string representation of the Basic Bank Account Number (BBAN), which
# contains only digits.
##
sub to_digit (_) {
    my $bban = shift;
    $bban = uc $bban;

    $bban =~ s/([A-Z])/(ord $1) - 55/eg;

    $bban;
} 

##
# Computes the key corresponding to a given International Bank Account Number
# (IBAN)
#
# @param country_code A string representation of the country code converted into IBAN  digits.
# @param bban A string representation of the Basic Bank Account Number (BBAN)
# with its key part and converted into IBAN digits.
#
# @return The IBAN key computed.
##
sub compute_key {
    my $country_code = shift;
    my $bban = shift;

    my $iban = $bban.$country_code.'00';

    my $rest = 0;
    map { $rest = ($rest * 10 + $_ ) % 97 } split //, $iban;

    my $key = 98 - $rest;
    if($key < 10)
    {
        $key = '0'.$key;
    }

    $key;
}

##
# Computes and returns the International Bank Account Number (IBAN)
# corresponding to the given country code and Basic Bank Account Number (BBAN).
#
# @param country_code The country code (i.e. "FR" for France, "DE" for Germany,
# etc.).
# @param bban Yhe Basic Bank Account Number (BBAN).
#
# @return A string representation of the International Bank Account Number
# (IBAN) with the key part. The returned IBAN can contains alpha and digit
# characters.
##
sub get_IBAN {
    my $country_code = uc shift;
    my $bban = shift;

    my $country_code_digit = to_digit($country_code);
    my $bban_digit = to_digit($bban);

    my $iban_key = compute_key($country_code_digit, $bban_digit);

    format_with_spaces($country_code.$iban_key.$bban);
}

##
# Formats the IBAN provided and separate each 4 digit with a space.
#
# @param iban   The IBAN provided.
#
# @return The IBAN separated each 4 digit with a space.
##
sub format_with_spaces {
    my $iban = shift;
    $iban =~ s/ //g;
    # Only works with French account with an IBAN length of 27 characters.
    # The following instruction selects longuest match first: 4 characters if
    # available, else 3 characters.
    join ' ', ($iban =~ /.{3,4}/g);
}

1;
