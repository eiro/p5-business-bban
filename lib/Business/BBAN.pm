# ABSTRACT: helpers to compute BBAN key and generate an BBAN. 

package Business::BBAN;  
use Modern::Perl;
our $VERSION = '0.0'; 



##
# Package helper to compute BBAN key and generate an BBAN from a bank
# identifier, a bank location identifier and an account identifier.
#
# @author Vincent Lucas
##

##
# Converts alpha characters into digit following the described table (beware,
# there is a gap between R and S):
#
#   Char        | Digit
#   --------------------
#   A, J        | 1
#   B, K, S     | 2
#   C, L, T     | 3
#   D, M, U     | 4
#   E, N, V     | 5
#   F, O, W     | 6
#   G, P, X     | 7
#   H, q, Y     | 8
#   I, R, Z     | 9
#
# @param bban   A string representation of the Basic Bank Account Number (BBAN),
# which can contains some alpha caracters.
#
# @return A string representation of the Basic Bank Account Number (BBAN), which
# contains only digits.
##
sub to_digit (_) {
    my $bban = shift;
    $bban = uc $bban;

    $bban =~ s/([A-R])/(((ord $1) - 56) % 9) + 1/eg;
    $bban =~ s/([S-Z])/(((ord $1) - 56) % 9) + 2/eg;

    $bban;
} 

##
# Computes the key corresponding to a given Basic Bank Account Number (BBAN)
#
# @param bban   A string representation of the Basic Bank Account Number (BBAN),
# which contains only digits, but does not contains the key part.
#
# @return The computed key of the BBAN given in parameter.
##
sub compute_key (_) {
    my $bban = shift.'00';
    my $rest = 0;
    map { $rest = ($rest * 10 + $_ ) % 97 } split //, $bban;
    my $key = 97 - $rest;
    if($key < 10)
    {
        $key = '0'.$key;
    }

    $key;
}

##
# Computes and returns the Basic Bank Account Number (BBAN) corresponding to the
# given bank identifier, bank location identifier and the account identifier.
#
# @param bank_id            The bank identifier.
# @param bank_locaiton_id   The bank location identifier.
# @param account_id         The account identifier.
#
# @return A string representation of the Basic Bank Account Number (BBAN) with
# the key part. The returned BBAN can contains alpha and digit characters.
##
sub get_BBAN {
    my $bank_id = shift;
    my $bank_location_id = shift;
    my $account_id = shift;

    my $bban = $bank_id.$bank_location_id.$account_id;
    my $bban_digit = to_digit($bban);
    my $bban_key = compute_key($bban_digit);

    $bban.$bban_key;
}

1;
