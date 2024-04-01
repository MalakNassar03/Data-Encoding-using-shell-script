#!/bin/bash
#malak nassar 1200757
#tala flaifel 1201107
array=""

is_encoded(){

# Prompt the user for the name of the feature
echo -n "Enter the name of the feature: "
read feature_name

# Read the first line of the file, which should contain the feature names
header=$(head -n 1 $filename)

# Extract the index of the feature you want to check
index=$(echo $header | tr ';' '\n' | grep -n "$feature_name" | cut -d':' -f1)

# Extract the values of the feature from the data set
values=$(tail -n +2 $filename | cut -d';' -f$index)

# Count the number of values in the column
num_values=$(echo "$values" | wc -l)

# Count the number of numerical values in the column
num_numerical=$(echo "$values" | grep -P '^\d+$' | wc -l)

# Check if all the values in the column are numerical
if [ $num_values -eq $num_numerical ]; then
  echo "Feature is label encoded"
else
  echo "Feature is not label encoded"
  
fi

}
#************************************************************************************
scalling(){
is_encoded

# Check if the feature exists in the dataset
  feature_line=$(echo "$firstline" | tr ';' ' ')
  if  grep -iq  "\<$feature_name\>" <<< "$feature_line"
   then
#if ! grep -q "$feature_name" $feature_line; then
  #echo "The name of the feature is wrong"
  # Return to main menu
 # return
#fi


# Read the first line of the dataset (which should contain the field names)
read -r field_names <<< "$(head -n1 $filename)"

# Split the field names into an array
IFS=';' read -r -a field_array <<< "$field_names"


# Find the index of the feature
feature_index=-1
index=0
while [ "${field_array[$index]}" ]; do
  if [ "${field_array[$index]}" = "$feature_name" ]; then
    feature_index="$index"
    break
  fi
  index=$((index+1))
  shift
done

# Read the values of the feature from the data file
values_=$(tail -n +2 $filename | cut -d ";" -f $((feature_index+1)))


# Find the minimum and maximum values of the feature
min=$(echo "$values_" | sort -n | head -n 1)
max=$(echo "$values_" | sort -n | tail -n 1)

echo "Minimum value: $min"
echo "Maximum value: $max"



#outting the values into an array each value has its own index
# Initialize an empty array
array=()

# Use a while loop to iterate through the output of the tail and cut commands
while read -r value; do
  # Append the value to the array
  array+=("$value")
done < <(tail -n +2 "$filename" | cut -d ";" -f $((feature_index+1)))

for i in "${!array[@]}"; do
  value="${array[$i]}"
  echo "Value at index $i: $value"
  t=$(($value-$min)) 
  m=$(($max-$min)) 

#apply the scalling to the data 
   scaled_value=$(echo "$t/$m" | bc -l)
 
  array[$i]="$scaled_value"
  echo "${array[$i]}"
done
else
echo "The name of the feature is wrong"
fi


}
#**************************************************************************************
distinct_values(){

# Read the first line of the dataset (which should contain the field names)
read -r field_names <<< "$(head -n1 $filename)"

# Split the field names into an array
IFS=';' read -r -a field_array <<< "$field_names"

# Find the index of the categorical feature
feature_index=-1
for i in "${!field_array[@]}"; do
  if [ "${field_array[$i]}" = "$feature" ]; then
    feature_index="$i"
    break
  fi
done

# Extract the distinct values of the categorical feature
values=$(cut -d';' -f"$((feature_index+1))" $filename | tail -n +2 | sort | uniq)

# Print the distinct values
echo "The distinct values of the $feature feature are: $values"

# Return 
return

}
#*******************************************************************************
# Function to perform one-hot encoding on a categorical feature
one_hot_encoding(){
read -p "Please input the name of the categorical feature:" feature

  feature_line=$(echo "$firstline" | tr ';' ' ')
  if  grep -iq  "\<$feature\>" <<< "$feature_line"
   then
   # Call the distinct_values function to extract the distinct values of the categorical feature
distinct_values
#outting the values into an array each value has its own index
# Initialize an empty array
array=()

# Use a while loop to iterate through the output of the tail and cut commands
while read -r values; do
  # Append the value to the array
  array+=("$values")
  
done < <(cut -d';' -f"$((feature_index+1))" $filename | tail -n +2 | sort | uniq )

echo "${array[@]}" #uniq values


#outting the values into an array each value has its own index
# Initialize an empty array
array1=()

# Use a while loop to iterate through the output of the tail and cut commands
while read -r value; do
  # Append the value to the array
  array1+=("$value")
done < <(tail -n +2 "$filename" | cut -d ";" -f $((feature_index+1)))


 
  # Loop through the array and create a sed command to add a new column for each unique value of the categorical feature
  for i in "${!array[@]}"; do
  
  # Extract the first line of the file
  header=$(head -n 1 $filename)

  # Append the value of the array to the first line
  new_header="${header}${array[$i]};"

  # Replace the first line of the file with the modified header
  sed -i "1s/.*/$new_header/" $filename

# Initialize a counter
k=2
t=0
 
# Use a while loop to read the rows of the file one by one
while read -r row; do

  
  # Check if the value of the row is equal to the value of the array
 # if grep -iq "${field_array[$feature_index]}" <<<  "${array[$i]}"; then
  if [ "${array1[$t]}" = "${array[$i]}" ]; then
  
    # Modify the row to add a 1 to the end
    sed -i "${k}s/$/1;/g" $filename
  # Otherwise, add a zero to the new column
  else
    sed -i "${k}s/$/0;/g" $filename
  fi
  # Increment the counter
k=$((k+1))
  t=$((t+1))
done < $filename
done

else
echo "The name of the categorical feature is wrong"
  # Return to main menu
  
fi
}

#*************************************************************************************************
label_encoding(){
#replace all the ; in the firstline to a space
feature_line=$(echo "$firstline" | tr ';' ' ')
#print the feature line
echo "$feature_line"
read -p "Please input the name of the categorical feature for label encoding:" feature
  feature_line=$(echo "$firstline" | tr ';' ' ')
  if  grep -iq  "\<$feature\>" <<< "$feature_line"
   then
distinct_values

temp_file=$(mktemp)
#read the file line by line then store it in fields
while  IFS= read -r line; do
 IFS=';' read -r -a fields <<< "$line"

array1=()

# Use a while loop to iterate through the output of the tail and cut commands
while read -r value; do
  # Append the value to the array
  array1+=("$value")
done < <(cut -d';' -f "$((feature_index+1))" $filename | tail -n +2 | sort | uniq)


value_index=0
#loop throught array that has the values
  for k in "${!array1[@]}"; do
  #if the element equals any element in the feilds array then label encode
 if grep -iq  "${array1[$k]}" <<< "${fields[$feature_index]}"; then
 echo "${array1[$k]}"
 echo $k
fields[$feature_index]="$k"
fi
done

# Write the modified line to the temporary file
 echo "${fields[*]};" >> "$temp_file"


done < $filename
#move data from temp to filename
mv "$temp_file" "$filename"
#change the spaces to ; in the file 
sed -i 's/ /;/g' $filename
else
echo "The name of the categorical feature is wrong"
  # Return to main menu
  
fi
}
#***********************************************************************************
while true;
do
echo "r)read a dataset from file "
echo "p)print the names of the features "
echo "l)encode a feature using label encoding "
echo "o)encode a feature using one_hot encoding "
echo "m)apply MinMax scalling "
echo "s)save the processed dataset "
echo "e)exit"
#ask the user for an input then read it 
read -p "please enter your choice: " sel
case "$sel" in 
#if it equals r
	"r")
	#take the file name from the user 
	read -p "please input the name of the datasetfile: " filename
	#if the file exists
 if [ -e "$filename" ]
then
#check if the dataset is clean by counting the number of ; in the line 
firstline=$(head -n 1 $filename)
count_first=$(echo $firstline | grep -o ";" | wc -l)
secondline=$(sed -n '2p' $filename)
count_second=$(echo $secondline | grep -o ";" | wc -l)
if [ "$count_first" -eq "$count_second" ]
then
echo "data is clean" 
# Read the first line of the file
read -r header < $filename

# Split the header into an array using ";" as the delimiter
IFS=';' read -r -a header_array <<< "$header"

# Loop through the rest of the file, split each line into an array using ";" as the delimiter, and print the values
while read -r line; do
    IFS=';' read -r -a line_array <<< "$line"
    #for i in "${!header_array[@]}"; do
       # echo "${header_array[i]}: ${line_array[i]}"
    #done
done < $filename

else 
echo "The format of the data in the dataset file is wrong"
fi
#******************************************************************************************
else
echo "file does not exist"
fi
;;
	"p")
array=$(echo "${line_array[@]}")
	if [ -z "$array" ] #if array ==null
 then
  echo "you must first read the dataset from file"
else

  echo "$firstline" | tr ';' ' ' #changed the delimiter from semicolon to  a space
fi
;;
#******************************************************************************
	"l")
array=$(echo "${line_array[@]}")
        if [ -z "$array" ] #if array ==null
 then
  echo "you must first read the dataset from file"
else
label_encoding
fi
;;
	"o")
	array=$(echo "${line_array[@]}")
	if [ -z "$array" ] #if array ==null
 then
  echo "you must first read the dataset from file"
else
one_hot_encoding
fi
;;
	"m")
	array=$(echo "${line_array[@]}")
	if [ -z "$array" ] #if array ==null
 then
  echo "you must first read the dataset from file"
else
scalling
fi
;;
	"s")
	array=$(echo "${line_array[@]}")
	if [ -z "$array" ] #if array ==null
 then
  echo "you must first read the dataset from file"
else
	read -p "Please input the name of the file to save the processed dataset " filesave
        new_file=$(cat $filename)
	echo "$new_file" > $filesave
	save=$(cat $filesave)
	fi
;;
	"e")
	if [ -z "$save" ]
then 
echo "the processed dataset is not saved."
echo " Are you sure you want to exist (YES or NO)"
read choice
if grep -iq "^YES$" <<< "$choice" ; 
then 
exit 0
else if grep -iq "\<$choice\>" <<< "^no$" ;
then
true
else 
echo "choice doesnt exists"
fi
fi

else
echo "Are you sure you want to exist (YES or NO)"
read choice_exit
if grep -iq "^YES$" <<< "$choice_exit" ;
then 
exit 0
else if grep -iq "\<$choice_exit\>" <<< "^no$" ;
then
echo "main menu"
else 
echo "choice doesnt exists"
fi
fi
fi
;;
	*)
echo " INVALID PLEASE TRY AGAIN!! "
;;
esac
done

