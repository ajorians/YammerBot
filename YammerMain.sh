#!/bin/bash

cd /home/ajorians/temp

curlOutputFilename="yammer_main_messages.txt"
limitingfilename="yammer_limits.txt"
dailylimitfilename="yammer_"$(date +%Y-%m-%d.txt)

groupid="<Withheld>"
bearertoken="<Withheld>"

curl -X GET https://www.yammer.com/api/v1/messages/in_group/$groupid.json?threaded=false -H "Authorization: Bearer $bearertoken" -H "Content-Type: application/json" > $curlOutputFilename

numMessages=$(cat $curlOutputFilename | jq .messages | jq length)

function handleMessage {

messageIndex=$1

message=$(cat $curlOutputFilename | jq '.messages['$messageIndex'].content_excerpt')
messagetype=$(cat $curlOutputFilename | jq '.messages['$messageIndex'].message_type')
createdat=$(cat $curlOutputFilename | jq '.messages['$messageIndex'].created_at')
url=$(cat $curlOutputFilename | jq '.messages['$messageIndex'].web_url')
repliedToId=$(cat $curlOutputFilename | jq '.messages['$messageIndex'].replied_to_id')

# Remove double quotes from message
temp="${message%\"}"
temp="${temp#\"}"
message=$temp

# Remove double quotes from messagetype
temp="${messagetype%\"}"
temp="${temp#\"}"
messagetype=$temp

# Remove double quotes from created at
temp="${createdat%\"}"
temp="${temp#\"}"
createdat=$temp

# Remove double quotes from url
temp="${url%\"}"
temp="${temp#\"}"
url=$temp

#if [[ $messagetype != "announcement" ]]; then
#   return
#fi

if [[ $repliedToId != "null" ]]; then
   return
fi

#echo "Message is"
#echo $message

postmessage=0

if [ -f "$limitingfilename" ]; then
   #echo "Using existing limiting file"

   line1=""
   line2=""
   line3=""
   line4=""
   line5=""
   line6=""
   line7=""
   line8=""
   line9=""
   line10=""
   line11=""
   line12=""
   line13=""
   line14=""
   line15=""
   line16=""
   line17=""
   line18=""
   line19=""
   line20=""
   while read line;
   do
      #echo "$line"
      if [[ $line1 = "" ]]; then
         line1=$line
      elif [[ $line2 = "" ]]; then
         line2=$line
      elif [[ $line3 = "" ]]; then
         line3=$line
      elif [[ $line4 = "" ]]; then
         line4=$line
      elif [[ $line5 = "" ]]; then
         line5=$line
      elif [[ $line6 = "" ]]; then
         line6=$line
      elif [[ $line7 = "" ]]; then
         line7=$line
      elif [[ $line8 = "" ]]; then
         line8=$line
      elif [[ $line9 = "" ]]; then
         line9=$line
      elif [[ $line10 = "" ]]; then
         line10=$line
      elif [[ $line11 = "" ]]; then
         line11=$line
      elif [[ $line12 = "" ]]; then
         line12=$line
      elif [[ $line13 = "" ]]; then
         line13=$line
      elif [[ $line14 = "" ]]; then
         line14=$line
      elif [[ $line15 = "" ]]; then
         line15=$line
      elif [[ $line16 = "" ]]; then
         line16=$line
      elif [[ $line17 = "" ]]; then
         line17=$line
      elif [[ $line18 = "" ]]; then
         line18=$line
      elif [[ $line19 = "" ]]; then
         line19=$line
      elif [[ $line20 = "" ]]; then
         line20=$line

      fi
   done < $limitingfilename

   if [[ $line1 == $createdat || $line2 == $createdat || $line3 == $createdat || $line4 == $createdat || $line5 == $createdat || $line6 == $createdat || $line7 == $createdat || $line8 == $createdat || $line9 == $createdat || $line10 == $createdat || $line11 == $createdat || $line12 == $createdat || $line13 == $createdat || $line14 == $createdat || $line15 == $createdat || $line16 == $createdat || $line17 == $createdat || $line18 == $createdat || $line19 == $createdat || $line20 == $createdat ]]; then
      echo "$messageIndex is already present"
   else
      echo "$messageIndex is a new entry"
      line20=$line19;
      line19=$line18;
      line18=$line17;
      line17=$line16;
      line16=$line15;
      line15=$line14;
      line14=$line13;
      line13=$line12;
      line12=$line11;
      line11=$line10;
      line10=$line9;
      line9=$line8;
      line8=$line7;
      line7=$line6;
      line6=$line5;
      line5=$line4;
      line4=$line3;
      line3=$line2;
      line2=$line1;
      line1=$createdat;

      echo -e "$line1\n$line2\n$line3\n$line4\n$line5\n$line6\n$line7\n$line8\n$line9\n$line10\n$line11\n$line12\n$line13\n$line14\n$line15\n$line16\n$line17\n$line18\n$line19\n$line20" > $limitingfilename      
      #echo -e "$line20\n$line19\n$line18\n$line17\n$line16\n$line15\n$line14\n$line13\n$line12\n$line11\n$line10\n$line9\n$line8\n$line7\n$line6\n$line5\n$line4\n$line3\n$line2\n$line1" > $limitingfilename

# Post this new entry to a flow
      postmessage=1
   fi
else
   echo "$messageIndex No limiting file; creating one"
   echo -e "$createdat" > $limitingfilename

# Post this entry to a flow
   postmessage=1
fi

if [ $postmessage = "1" ]; then
   currentlimit=5
   if [ -f "$dailylimitfilename" ]; then
      currentlimit=$(cat $dailylimitfilename)
      currentlimit=$(($currentlimit-1))

      if [ $currentlimit -lt 1 ]; then
         echo "Reached daily maximum posts; exiting"
         exit 1
      fi
   fi

   echo $currentlimit > $dailylimitfilename

   #Replace double quotes with escaped ones such that I can do a REST post
   message=$(echo $message|sed 's/\"/\\\"/g')

   exactmessage="$url\r\n$message #officialcommunication"
   #exactmessage="[$message]($url) #officialcommunication"

   postdata="{\"event\":\"message\",\"external_user_name\":\"Yammer_bot\",\"content\":\"$exactmessage\"}"

   echo "$messageIndex Posting message which was created at $createdat"
   #echo $postdata


#curl --header "Content-Type: application/json" \
#  --request POST \
#  --data "$postdata" \
#  -u ajorians@gmail.com:<Withheld> \
#  https://api.flowdock.com/flows/aj-org/main/messages

fi

}

for((i=$numMessages-1;i>=0;--i)) do
   handleMessage $i
done

