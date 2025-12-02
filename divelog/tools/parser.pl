#!/usr/bin/perl -w 
#
# initialize some variables #################################################

#$path="/Users/hekatzgr/Desktop/divelog";
$path="/Users/hgk/Sites/katzgraber.org/divelog";
$sites="sites/";
$file="log.dat";
$verbose=0;
$date=`date +%d/%m/%y`;

@id 	   = 0;
@location  = 0;
@site	   = 0;
@date	   = 0;
@time	   = 0;
@depth	   = 0;
@divetime  = 0;
@tank      = 0;
@pressure  = 0;
@volume    = 0;
@air       = 0;
@kilos     = 0;
@suit	   = 0;
@buddy     = 0;
@guide     = 0;
@link      = 0;
@tech      = 0;
@comments  = 0;

$counter   = 0;

# read in data ##############################################################

open(DATA, "$path/data/$file");
while (<DATA>){
    chomp;

    if ($_ =~ /^id/){
	$id[$counter] 		= (split /^id\s+/)[1];
	next;
    }
    if ($_ =~ /^location/){
	$location[$counter] 	= (split /^location\s+/)[1];
	next;
    }
    if ($_ =~ /^site/){
	$site[$counter] 	= (split /^site\s+/)[1];
	next;
    }
    if ($_ =~ /^date/){
	$date[$counter] 	= (split /^date\s+/)[1];
	next;
    }
    if ($_ =~ /^time/){
	$time[$counter] 	= (split /^time\s+/)[1];
	next;
    }
    if ($_ =~ /^depth/){
	$depth[$counter] 	= (split /^depth\s+/)[1];
	next;
    }
    if ($_ =~ /^divetime/){
	$divetime[$counter] 	= (split /^divetime\s+/)[1];
	next;
    }
    if ($_ =~ /^tank/){
	$tank[$counter] 	= (split /^tank\s+/)[1];
	next;
    }
    if ($_ =~ /^pressure/){
	$pressure[$counter] 	= (split /^pressure\s+/)[1];
	next;
    }
    if ($_ =~ /^volume/){
	$volume[$counter]     = (split /^volume\s+/)[1];
	next;
    }
    if ($_ =~ /^air/){
	$air[$counter]     = (split /^air\s+/)[1];
	next;
    }
    if ($_ =~ /^temp/){
	$temperature[$counter]  = (split /^temp\s+/)[1];
	next;
    }
    if ($_ =~ /^kilos/){
	$kilos[$counter] 	= (split /^kilos\s+/)[1];
	next;
    }
    if ($_ =~ /^suit/){
	$suit[$counter] 	= (split /^suit\s+/)[1];
	next;
    }
    if ($_ =~ /^buddy/){
	$buddy[$counter] 	= (split /^buddy\s+/)[1];
	next;
    }
    if ($_ =~ /^guide/){
	$guide[$counter] 	= (split /^guide\s+/)[1];
	next;
    }
    if ($_ =~ /^link/){
	$link[$counter] 	= (split /^link\s+/)[1];
	next;
    }
    if ($_ =~ /^tech/){
	$tech[$counter]         = (split /^tech\s+/)[1];
	next;
    }
    if ($_ =~ /^comments/){
	$comments[$counter] 	= (split /^comments\s+/)[1];
	next;
    }

    if ($_ =~ /^#######/){
	$counter++;
	next;
    }
}

# make statistics on dive depth #############################################

$depth_max = $depth[0];
$depth_min = $depth[0];
for($i = 1; $i < $counter; $i++){
    if($depth[$i] > $depth_max){
	$depth_max = $depth[$i];
    }
    if($depth[$i] < $depth_min){
	$depth_min = $depth[$i];
    }
}

$depth_mean   = 0;
for($i = 1; $i < $counter; $i++){
    $depth_mean += $depth[$i];
}
$depth_mean   /= $counter;

$depth_stddev = 0;
for($i = 1; $i < $counter; $i++){
    $depth_stddev += ($depth[$i] - $depth_mean)**2;
}
$depth_stddev /= ($counter - 1);
$depth_sigma   = sqrt($depth_stddev);

$binsize = 1;
$nbins   = 35;
@histo   = 0;

for($k = 1; $k <= $nbins; $k++){
    $binmin    = ($k-1)*$binsize;
    $binmax    = $k*$binsize;
    $histo[$k] = 0;
    for($i = 1; $i < $counter; $i++){
	if(($depth[$i]>$binmin)&&($depth[$i]<= $binmax)){
	    $histo[$k] += 1;
	}
    }
}

open(TMP, ">>/tmp/.data") || die "cannot open: $!";
for($k = 1; $k <= $nbins; $k++){
        $bin = ($k-1)*$binsize;
	    print(TMP "$bin $histo[$k]\n");
}
close(TMP);
&generate_dplo("$path/pics/depth_histo.jpeg","max depth [m]",45);
unlink("/tmp/.data");


printf("\nmax depth      max %3.2fm\tmin %3.2fm\tmean %3.2fm +/- %3.2fm \n",
	$depth_max,
	$depth_min,
	$depth_mean,
	$depth_sigma
	);

# make statistics on dive time ##############################################

$divetime_max = $divetime[0];
$divetime_min = $divetime[0];
for($i = 1; $i < $counter; $i++){
    if($divetime[$i] > $divetime_max){
	$divetime_max = $divetime[$i];
    }
    if($divetime[$i] < $divetime_min){
	$divetime_min = $divetime[$i];
    }
}

$divetime_mean   = 0;
for($i = 1; $i < $counter; $i++){
    $divetime_mean += $divetime[$i];
}
$divetime_mean   /= $counter;

$divetime_stddev = 0;
for($i = 1; $i < $counter; $i++){
    $divetime_stddev += ($divetime[$i] - $divetime_mean)**2;
}
$divetime_stddev /= ($counter - 1);
$divetime_sigma   = sqrt($divetime_stddev);

$binsize = 2;
$nbins   = 50;
@histo   = 0;

for($k = 1; $k <= $nbins; $k++){
    $binmin    = ($k-1)*$binsize;
    $binmax    = $k*$binsize;
    $histo[$k] = 0;
    for($i = 1; $i < $counter; $i++){
	if(($divetime[$i]>$binmin)&&($divetime[$i]<= $binmax)){
	    $histo[$k] += 1;
	}
    }
}

open(TMP, ">>/tmp/.data") || die "cannot open: $!";
for($k = 1; $k <= $nbins; $k++){
    $bin = ($k-1)*$binsize;
    print(TMP "$bin $histo[$k]\n");
}
close(TMP);
&generate_dplo("$path/pics/time_histo.jpeg","dive time [min]",90);
unlink("/tmp/.data");

printf("divetime       max %3.2f'\tmin %3.2f'\tmean %3.2f' +/- %3.2f'\n",
	$divetime_max,
	$divetime_min,
	$divetime_mean,
	$divetime_sigma
      );
$divetime_total   = $divetime_mean*$counter;
$divetime_total_h = $divetime_total/60;
printf("total time     %d' (%3.1fh)\n",$divetime_total,$divetime_total_h);

$eancounter = 0;
for($i = 0; $i < $counter; $i++){
    if($air[$i] =~ /EAN/){
	$eancounter++;
    }
}
$aircounter = $counter - $eancounter;

$nicounter = 0;
for($i = 0; $i < $counter; $i++){
    if($time[$i] =~ /NI/){
	$nicounter++;
    }
}

printf("dive count     %d logged dives (%d air, %d nitrox, %d at night)\n",
        $counter,
        $aircounter,
        $eancounter,
	$nicounter
        );

$ugcounter = 0;
for($i = 0; $i < $counter; $i++){
    if($guide[$i] =~ /Unguided/){
        $ugcounter++;
    }
}
$gcounter = $counter - $ugcounter;

printf("guiding        %d independent dives (%d guided)\n\n",
	$ugcounter,
	$gcounter
	);

# generate log pages ########################################################

for($i = 0; $i < $counter; $i++){
    $index = $i + 1;

    if($index < 10){
	$logname = "00"."$index";
    }
    if(($index > 9) && ($i < 100)){
	$logname = "0"."$index";
    }
    if($index > 99){
	$logname = "$index";
    }

    if($index == 1){
	$pindex = $counter;
	$nindex = $index + 1;
    }
    elsif($index == $counter){
	$pindex = $index - 1;
	$nindex = 1;
    }
    else{
	$pindex = $index - 1;
	$nindex = $index + 1;
    }

    if($nindex < 10){
	$nlogname = "00"."$nindex";
    }
    if(($nindex > 9) && ($i < 100)){
	$nlogname = "0"."$nindex";
    }
    if($nindex > 99){
	$nlogname = "$nindex";
    }

    if($pindex < 10){
	$plogname = "00"."$pindex";
    }
    if(($pindex > 9) && ($i < 100)){
	$plogname = "0"."$pindex";
    }
    if($pindex > 99){
	$plogname = "$pindex";
    }
    
    if($tank[$i] eq "alu"){
	$tankname = "Aluminum";
    }
    elsif($tank[$i] eq "fe"){
	$tankname = "Steel";
    }
    else{
	printf("problem in tankname for dive %d\n",$id[$i]);
	exit;
    }

    if($air[$i] eq "Air"){
	$airname = "Air";
    }
    elsif($air[$i] eq "EAN32"){
	 $airname = "EAN32";
    }
    elsif($air[$i] eq "EAN36"){
	$airname = "EAN36";
    }
    else{
	printf("problem in airname for dive %d\n",$id[$i]);
	exit;
    }

    if($temperature[$i]){
	$celsius = "$temperature[$i]"."C";
    }
    else{
	$celsius = "N/A";
    }

    if($time[$i] eq "NI"){
	$time[$i] = "Night";
    }

    if($link[$i] eq "None"){
	$photo = "";
    }
    else{
	$photo = "photos";
    }

    unlink("$path/sites/dive-$logname.html");

    open(HTML2, ">>$path/$sites/dive-$logname.html") || die "cannot open: $!\n";
    print(HTML2 "
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html>

<head>
    <link rel=\"stylesheet\"
	  type=\"text/css\"
	  href=\"https://katzgraber.org/styles/katzgraber.css\"
	  media=\"screen\">
    <title>Dive $logname - $date[$i]</title>
</head>

<body>

<br><br><br><br><br>

<blockquote><blockquote>

<fieldset>
<legend>Dive $logname &nbsp $date[$i]</legend>
<table width=45% border=0 cellspacing=0 cellpadding=4 align=left valign=top>

<tr bgcolor=#ffffff class=\"hide\">
    <td align=right>
    <a class=\"inv\" href=\"https://katzgraber.org/divelog/sites/dive-$plogname.html\">
    prev</a> |
    <a class=\"inv\" href=\"https://katzgraber.org/divelog/sites/dive-$nlogname.html\">
    next</a>
    &nbsp; &nbsp; &nbsp; &nbsp;
    <a class=\"inv\" href=\"https://katzgraber.org/divelog/\">
    back
    </a>
    </td>

    <td align=right>
    <a href=\"$link[$i]\">
    $photo
    </a>
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td width=40%>
    &nbsp;
    </td>
    <td>
    &nbsp;
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td colspan=2>
    <font color=\"black\">
    $location[$i], $site[$i]
    </font>
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td width=20%>
    &nbsp;
    </td>
    <td>
    &nbsp;
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Time
    </td>

    <td>
    $time[$i]
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Max. depth
    </td>

    <td>
    $depth[$i]m
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Divetime 
    </td>
    
    <td>
    $divetime[$i]'
    </td>
</tr>    

<tr bgcolor=#ffffff>
    <td>
    Pressure used
    </td>

    <td>
    $pressure[$i]bar
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Tank type
    </td>

    <td>
    $tankname
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Tank volume
    </td>

    <td>
    $volume[$i]l
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Gas mixture
    </td>

    <td>
    $airname
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Water temperature
    </td>

    <td>
    $celsius
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Suit used
    </td>

    <td>
    $suit[$i]
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Weights
    </td>

    <td>
    $kilos[$i]kg
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Buddy / Guide
    </td>

    <td>
    $buddy[$i] / $guide[$i]
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td>
    Techn. Commments
    </td>

    <td>
    $tech[$i]
    </td>
</tr>

<tr bgcolor=#ffffff>
    <td valign=top>
    Comments
    </td>

    <td valign=top>
    $comments[$i]
    </td>
</tr>

</table>

<br><br>

");

    $imgname = "$path/profiles/$logname.png";
    if (-e $imgname) {
	open(HTML2, ">>$path/$sites/dive-$logname.html") || die "cannot open: $!\n";
	print(HTML2 "
<table width=45% border=0 cellspacing=0 cellpadding=4 align=left>

<tr bgcolor=#ffffff>
<td>
    &nbsp;<br>&nbsp;<br>&nbsp;<br>&nbsp;<br>
    </td>
</tr>

<tr bgcolor=#ffffff>
<td>
    <img src=\"../profiles/$logname.png\" width=\"600\" border=1>
    </td>
</tr>

</table>

<br><br>

</body>

</html>
");
    }
}

# make index file for dives #################################################

unlink("$path/index.html");
open(HTML, ">>$path/index.html") || die "cannot open: $!\n";
print(HTML "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/99/xhtml\">
<head>
<link rel=\"SHORTCUT ICON\" href=\"images/icon.ico\">
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<title>Helmut G. Katzgraber</title>
<link rel=\"stylesheet\" href=\"https://katzgraber.org/styles/rpi/rpi.bundle.css\" >
<script type=\"text/javascript\" src=\"https://katzgraber.org/styles/rpi/rpi.bundle.js\"></script>
<link rel=\"stylesheet\" type=\"text/css\" href=\"https://katzgraber.org/styles/style.css\" />
</head>

<body>

<!-- progress bar -->
<div id=\"rpi-progress-bar-container\"
  role=\"progressbar\"
  aria-valuemin=\"0\"
  aria-valuemax=\"100\"
  aria-valuenow=\"0\">
    <div class=\"rpi-progress-bar-container__position\" aria-hidden=\"true\"></div>
    <div class=\"rpi-progress-bar-container__percentage\"></div>
</div>


<div id=\"all\" class=\"clearfix\">

<!-- navigation bar -->
<ul id=\"nav\">
        <li><a href=\"https://katzgraber.org\">katzgraber.org</a></li>
</ul>

<!-- page title -->
<h1 class=\"frontimage6\">
Divelog
&nbsp;
</h1>

<!-- page content -->
<div id=\"content\">

&nbsp;<br>

<h1>Statistics</h1>

<br>

<table width=95% border=0 cellspacing=0 cellpadding=5 align=center>

<tr bgcolor=#ffffff>
    <td colspan=3>
");

printf(HTML "	<b>Depth</b>:      max %3.2fm, min %3.2fm, mean %3.2fm &plusmn; %3.2fm <br>\n",
	$depth_max,
	$depth_min,
	$depth_mean,
	$depth_sigma
       );

printf(HTML "	<b>Divetime</b>:   max %3.2f', min %3.2f', mean %3.2f' &plusmn; %3.2f'<br>\n",
	$divetime_max,
	$divetime_min,
	$divetime_mean,
	$divetime_sigma
      );

printf(HTML "	<b>Total underwater time</b>: %d' (%3.1fh)<br>\n",
	$divetime_total,
	$divetime_total_h
      );

printf(HTML "   <b>Number of dives</b>: %d (%d air, %d nitrox, %d at night)<br>\n",
	$counter,
	$aircounter,
	$eancounter,
	$nicounter
      );

print(HTML "
<br><br>
</td>
</tr>
<tr bgcolor=#ffffff>
    <td colspan=3 align=center>"
);

printf(HTML "<img src=\"pics/time_histo.jpeg\" alt=\"[time]\" height=220>\n",);
printf(HTML "<img src=\"pics/depth_histo.jpeg\" alt=\"[depth]\" height=220>\n",);


print(HTML "
<br><br>
</td>
</tr>
</table>

<br>
<br>
");
close(HTML);

open(HTML, ">>$path/index.html") || die "cannot open: $!\n";

print(HTML "
<h1>Logged Dives</h1>

&nbsp;<br>

<table width=95% border=0 cellspacing=0 cellpadding=5 align=center>

");

$cc = 1;
for($i = ($counter - 1); $i >= 0; $i--){
    $index = $i + 1;
    $cc   += 1;
    if($index < 10){
	$logname = "00"."$index";
    }
    if(($index > 9) && ($i < 100)){
	$logname = "0"."$index";
    }
    if($index > 99){
	$logname = "$index";
    }
    
    if(($cc%2) == 0){
	print(HTML "
<tr bgcolor=#dcdcdc>
    <td width=20 valign=top>
    <a class=\"ainv\" href=\"https://katzgraber.org/divelog/sites/dive-$logname.html\">
    $logname
    </a>
    </td>

    <td valign=top>
    <a class=\"ainv\" href=\"https://katzgraber.org/divelog/sites/dive-$logname.html\">
     $date[$i]
    </a>
    </td>

    <td valign=top>
    <a class=\"ainv\" href=\"https://katzgraber.org/divelog/sites/dive-$logname.html\">
    $location[$i], $site[$i]
    </a>
    </td>
</tr>

");
    }
    if(($cc%2) == 1){
    	print(HTML "
<tr bgcolor=#ffffff>
    <td width=20 valign=top>
    <a class=\"inv\" href=\"https://katzgraber.org/divelog/sites/dive-$logname.html\">
    $logname
    </a>
    </td>
    
    <td valign=top>
    <a class=\"inv\" href=\"https://katzgraber.org/divelog/sites/dive-$logname.html\">
    $date[$i]
    </a>
    </td>

    <td valign=top>
    <a class=\"inv\" href=\"https://katzgraber.org/divelog/sites/dive-$logname.html\">
    $location[$i], $site[$i]
    </a>
    </td>
</tr>

");
    }
}

open(HTML, ">>$path/index.html") || die "cannot open: $!\n";
print(HTML "
<tr bgcolor=#ffffff>
    <td>
    </td>
    <td>
    </td>

    <td align=right><font color=#000000>
    <br>last update $date
</tr>

</table>

</div>

<div id=\"footer\">
<p>
<a class=\"front\" href=\"https://katzgraber.org/contact/\">web mgmt</a>
</p>
</div>

</div>

<!-- progress bar -->
<script>
var rpi = new ReadingPositionIndicator({
  color: 'rgba(255,0,0,.9)',
  percentage: {
    show: true,
    displayBeforeScroll: false,
    opacity: .0,
    color: '#ffffff',
  },
}).init();
</script>
<!-- end progress bar -->

</body>
</html>
");
close(HTML);

# print dive summary ########################################################

if($verbose == 1){
    print("\nID\tDATE     LOCATION\n");
    for($i = 0; $i < $counter; $i++){
	printf("%d\t%s %s, %s\n",
	    $id[$i],
	    $date[$i],
	    $location[$i],
	    $site[$i]
	    );
    }
}

# generate jpeg #############################################################

sub generate_dplo {
    my $image        = $_[0];
    my $label        = $_[1];
    my $plotrangemax = $_[2];
    open(GP,"|".GNUPLOT) || die "cannot open GNUPLOT: $!\n";
    print GP "set terminal jpeg linewidth 3 small font \"Trebuchet MS,28\" size 1100,700 
	set grid
	unset key
	set style data histeps
	set ytics 5
	set yrange [0:25]
	set xrange [0:$plotrangemax]
	set xlabel \"$label\"\n";
    close(TMP);
	print GP "set output '$image'\n";
	print GP "plot '/tmp/.data' lt rgb \"navy\"";
	close(GP);
}

