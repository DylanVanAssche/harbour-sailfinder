function calculate_age(birth_date)
{
    var birth_date_array = birth_date.split('-')
    var birth_year = parseInt(birth_date_array[0]) // year
    var birth_month = parseInt(birth_date_array[1]) // month
    birth_date_array = birth_date_array[2].split('T')
    var birth_day = parseInt(birth_date_array[0]) // day
    var today_date = new Date();
    var today_year = today_date.getFullYear();
    var today_month = today_date.getMonth();
    var today_day = today_date.getDate();
    var difference_years = today_year - birth_year;

    if ( today_month < (birth_month - 1))
    {
        difference_years--;
    }
    if (((birth_month - 1) == today_month) && (today_day < birth_day))
    {
        difference_years--;
    }
    return difference_years;
}

function time_difference(last_message_date, last_activity_date)
{
    var msg_date = new Date(last_message_date)
    var activity_date = new Date(last_activity_date)

    if(msg_date.getTime() > activity_date.getTime())
    {
        return true
    }
    else
    {
        return false
    }
}

function calculate_last_seen(last_activity_date)
{
    var now_date = new Date()
    var last_active_date = new Date(last_activity_date)
    now_date = now_date.getTime()
    last_active_date = last_active_date.getTime()
    var difference = now_date - last_active_date

    if(difference > (24*60*60*1000)) // More then 24 hours
    {
        var days = difference/(24*60*60*1000)
        days = parseInt(days)

        if(days > 7) // More then 7 days? return the date
        {
            var date = new Date(last_activity_date)
            return date.getDate() + '-' + date.getMonth() + '-' + date.getFullYear()
        }
        else
        {
            if(days != 1)
            {
                return days + qsTr(" days ago")
            }
            else
            {
                return days + qsTr(" day ago")
            }
        }
    }
    else if(difference >= (60*60*1000))
    {
        var hours = difference/(60*60*1000)
        hours = parseInt(hours)
        if(hours != 1)
        {
            return hours + qsTr(" hours ago")
        }
        else
        {
            return hours + qsTr(" hour ago")
        }
    }
    else if(difference >= (60*1000))
    {
        var minutes = difference/(60*1000)
        minutes = parseInt(minutes)
        if(minutes != 1)
        {
            return minutes + qsTr(" minutes ago")
        }
        else
        {
            return minutes + qsTr(" minute ago")
        }
    }
    else
    {
        return qsTr("just now")
    }
}

function superlike_reseted(superlike_reset_time)
{
    var now_date = new Date()
    var superlike_reset_date = new Date(superlike_reset_time)
    now_date = now_date.getTime()
    superlike_reset_date = superlike_reset_date.getTime()
    var difference = now_date - superlike_reset_date

    if(difference > 0)
    {
        return false
    }
    else
    {
        return true
    }
}
