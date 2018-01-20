rm MMLauncher.log

# default parameters

refreshTime=10
params=0
nRepeat=1
PID=0
mailoption=0

# get parameter options

while getopts "t:hf:c:r:m:p:" o; do
  case "${o}" in
  c)
    commands=${OPTARG}
    params=1
    ;;
  h)
    echo ""
    echo ""
    echo "------------Developed by Manuel Montero-------------"
    echo ""
    echo "----------------------HELP: Params------------------------"
    echo ""
    echo "-c <\"command\"> --> Command to execute"
    echo "-f <File path> --> File path with commands to execute"
    echo "    Example: "
    echo "      sleep 10"
    echo "      sh launcherProcess.sh"
    echo "-h Help"
    echo "-m <\"mail\"> mail to receive notifications (Using mailx). EX: \"manuel@email.com\"."
    echo "-p <PID> PID for active process"
    echo "-t <time in seconds> --> Time to refresh"
    echo "-r <number> --> Number of times to repeat the command. IMPORTANT: Use only with -c option"
    echo ""
    echo "----------------------HELP: Params------------------------"
    echo ""
    exit 0
    ;;
  f)
    readarray commands < ${OPTARG}
    params=1
    ;;
  m)
    mail=${OPTARG}
    mailoption=1
    ;;
  p)
    PID=${OPTARG}
    ;;
  r)
    nRepeat=${OPTARG}
    ;;
  t)
    refreshTime=${OPTARG}
    ;;
  *)
    echo "Unrecognized command."
    exit 0
    ;;
  esac
done

if [ $params -eq 0 ] ; then echo "No commands supplied. Use -h if you need help! =)"; exit 1; fi

# waiting for active process

if [ $PID -ne 0 ]; then
  pid=$PID
  start=`date +%s`
  while [ $(ps -o comm= -p "$pid") ]
    do
      sleep $refreshTime
      runtime=$((`date +%s`-start))
      echo "Waiting for active process with PID = ${pid} ... (Waiting time ${runtime}s)" >> MMLauncher.log
    done
    
    if [ $mailoption -ne 0 ] ; then echo "Starting execution after process with PID=${pid}." | mailx -s "Starting execution after process with PID=${pid}." $mail; fi
fi

alltime=`date +%s`
rmFile=0

for n in `seq 1 $nRepeat`;
do
  
  echo "" >> MMLauncher.log

  if [ $nRepeat -ne 1 ] ; then echo "Repetition number " $n >> MMLauncher.log; fi
  
  for i in "${commands[@]}"
  do
  
    
    $i &
    echo "$!" > ~/myprocess.txt
    rmFile=1
    pid=$(cat ~/myprocess.txt)
    echo "Command: " $i >> MMLauncher.log
    start=`date +%s`
    
    while [ $(ps -o comm= -p "$pid") ]
    do
      sleep $refreshTime
      runtime=$((`date +%s`-start))
      allexecutiontime=$((`date +%s`-alltime))
      echo "Executing... (Command time ${runtime}s) (Execution time ${allexecutiontime}s)" >> MMLauncher.log
    done
    
    if [ $mailoption -ne 0 ] ; then echo "Process ${i} finish." | mailx -s "Process ${i} finish." $mail; fi
  
  done
  
  if [ $nRepeat -ne 1 ] ; then echo ""; fi

done

if [ $rmFile -eq 1 ] ; then rm ~/myprocess.txt; fi

echo "" >> MMLauncher.log
echo "-------------------------" >> MMLauncher.log
echo "All commands was executed" >> MMLauncher.log
echo "-------------------------" >> MMLauncher.log

