#!/usr/bin/perl
use local::lib 'perl5';
use Mojo::DOM;
use Data::Dumper;
$Data::Dumper::Indent = 0;
{$/ = undef; $_ = <STDIN>;}
$dom = Mojo::DOM->new($_);
eval {
    $name = $dom->at(q{div[class="col-lg-9"] > div[class="panel"] > div > h2})->text;
};

die $_ if $@ =~ /Can't call method "text" on an undefined value/;

$dom = $dom->at(q{div[class="col-lg-9"] > div[class="panel content"]});
if ($dom->at(q{div[class="col-lg-12"] > p > a})) {
    $pdf = $dom->at(q{div[class="col-lg-12"] > p > a})->attr("href") ;
    $pdf =~ m{pdf/(\d*)$};
}
$id = $ARGV[0] || $1;
$desc = $dom->at(q{div[class="col-lg-12"] > p})->text if $dom->at(q{div[class="col-lg-12"] > p});
if ($dom->at(q{div[class="col-lg-6"] > h4 ~ h4 + p})) {
	$_ = $dom->at(q{div[class="col-lg-6"] > h4 ~ h4 + p})->to_string;
	/>\s*(.*?)<br>.*E-mail: .*"mailto:\s*(.*?)\s*"/gms;
	$officer{Advisor} = [$1, $2];
} else {
	$officer{Advisor} = ['Unknown', 'unknown@umbc.edu'];
}
$officerPointer = $dom->at(q{div[class="col-lg-6"] > p});
do {
    if ($officerPointer->matches("p")) {
        $_ = $officerPointer->to_string;
        />\s*(.*?): (.*?)<br>.*E-mail: .*"mailto:\s*(.*?)\s*"/gms;
        $officer{$1} = [$2, $3];
    } else { $officerPointer = undef; }
} while ($officerPointer && ($officerPointer = $officerPointer->next));
$socPtr = $dom->at(q{div[class="col-lg-6 well"] > *});
%currMed = (
    "myUMBC group" => "m",
    Website=>"w",
    Facebook=>"f",
    Twitter=>"t",
    "Group Email"=>"e",
    Mailbox=>"b",
    Cabinet=>"c",
);
{
    if ($socPtr && $socPtr->next) {
        $currMed{$currMed{$socPtr->text}} = $socPtr->next->text;
        $currMed{$currMed{$socPtr->text}} = $socPtr->next->at("a")->attr("href") if $socPtr->next->at("a");
        $socPtr = $socPtr->next->next;
        redo;
    }
}
$officer .= "$_: \"$officer{$_}[0]\" <$officer{$_}[1]>, " foreach keys %officer;
$officer =~ s/\n//g;
chop $officer && chop $officer;
@currMed = @currMed{'m','w','f','t','e','b','c'};
$, =  "\t";
$" =  "\t";
print $id, $desc, $officer, "@currMed\n";

