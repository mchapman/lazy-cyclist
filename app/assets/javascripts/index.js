function doGeocoding(geocoder, address, field) {
    // clear all the values in case the form is submitted before we get back
    $('input#lat'+field).val('');
    $('input#lng'+field).val('');
    var inputGeog = $('input#geog'+field)
    $.data(document.body,'stash'+field,"");
    if (address.length > 0 && address !== inputGeog.attr('data-default')) {
        geocoder.geocode( { 'address': address+',UK'}, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                $('input#lat'+field).val(results[0].geometry.location.lat());
                $('input#lng'+field).val(results[0].geometry.location.lng());
                $.data(document.body,'stash'+field,address);
            } else {
                console.log('Failed to Geocode ' + address + '  ' + status);
            }
        });
    }
};

$(document).ready(function() {

    $('input.clear').each(function() {

        var def_val;

        def_val = $(this).attr('data-default');

        // if the field is blank put in the helper text
        if($(this).val() == '') {
            $(this)
                    .addClass('inactive_input')
                    .val(def_val)
        }

        $(this)
            // stash the helper text
                .data('default',def_val)

                .focus(function() {
                    $(this).removeClass('inactive_input');
                    if($(this).val() == $(this).data('default') || '') {
                        $(this).val('');
                    }
                })

                .blur(function() {
                    var default_val = $(this).data('default');
                    if($(this).val() == '') {
                        $(this).addClass('inactive_input');
                        $(this).val($(this).data('default'));
                    }
                });
    });

    $('input#submit').click(function() {
        var errs = [];
        var places = ['home','work']
        for(var i=1; i <= 2; i++) {
            var geogInput = $('input#geog'+i);
            var address = geogInput.val();
            var hasGeog = (address !== geogInput.attr('data-default'));
            if (!hasGeog)  { errs.push("You must specify a " + places[i-1] + " address."); }
            var stashedAddress = $.data(document.body,'stash'+i);
            if (address !== stashedAddress) {
                $('input#lat'+i).val('');
                $('input#lng'+i).val('');
            }
        }
        if (errs.length > 0) {
            $('#srcherr').remove();
            $('.span8').prepend('<div class="row" id="srcherr"><div class="span6 offset1"><div class="alert alert-error">'+errs.join('<br />')+'<a class="close" data-dismiss="alert" href="#">&times;</a></div></div></div>');
            return false;
        }
    });
});

function initialize() {
    var geocoder = new google.maps.Geocoder();

    // Set up function to do the geocoding when the town is changed
    for (var i=1; i<=2;i++) {
        $('input#geog'+i).blur(function() {
            var geogInput = $('input#geog'+i);
            var address = geogInput.val();
            var stashedAddress = $.data(document.body,'stash'+i);
            if (address !== stashedAddress) {
                doGeocoding(geocoder, address,i);
            }
        });
    }

    // Do the geocoding with what is passed unless we have a geog, lat and lng
    for (var i=1; i<=2;i++) {
        var geogInput = $('input#geog'+i)
        var address = geogInput.val();
        if ((address.length > 0 && $('input#lat'+i).val().length > 0 && $('input#lng'+i).val().length > 0) || (address === geogInput.attr('data-default'))) {
            // then we assume everything is OK and save making the API call.  Stash the data for comparison.
            $.data(document.body, 'stash'+i, address);
        } else {
            doGeocoding(geocoder, address, i);
        }
    }
};

function loadScript() {
    var script = document.createElement('script');
    script.type = 'text/javascript';
//    script.src = 'http://maps.googleapis.com/maps/api/js?key=AIzaSyAUKt0lVU8KLfdJWtowMS1Ih1cMIin59SM&sensor=false&callback=initialize';
    script.src = 'http://maps.googleapis.com/maps/api/js?sensor=false&callback=initialize';
    document.body.appendChild(script);
}

window.onload = loadScript;