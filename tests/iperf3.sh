#!/bin/bash

# ========== CONFIGURATION ==========
IPERF3_SERVER_IP="192.168.70.163"   # IP du conteneur iperf3-server (d'après ton docker-compose)
START_PORT=5201
DURATION=60  # Durée du test en secondes (par défaut 30)
NUM_UES=7
RETRIES=3
RESULTS_FILE="tests/iperf3_results.txt"

echo "===== Starting iPerf3 tests =====" > $RESULTS_FILE

# ========== MAIN LOOP ==========
for i in $(seq 1 $NUM_UES); do
  UE_NAME="ue$i"
  PORT=$((START_PORT + i))
  ATTEMPT=1

  echo "****************************************************"
  echo "Running iPerf3 test for $UE_NAME (port $PORT)..."

  while [ $ATTEMPT -le $RETRIES ]; do
    echo "Attempt $ATTEMPT for $UE_NAME on port $PORT"

    # On lance iperf3 depuis le conteneur de l'UE
    docker exec $UE_NAME iperf3 -c $IPERF3_SERVER_IP -p $PORT -t $DURATION >> "$RESULTS_FILE" 2>&1 &

    PID=$!
    wait $PID
    RESULT=$(tail -n 1 "$RESULTS_FILE")

    # Vérifie si la connexion a échoué
    if [[ "$RESULT" == *"refused"* || "$RESULT" == *"unable"* || "$RESULT" == "command terminated with exit code 1" ]]; then
      echo "Connection refused for $UE_NAME on port $PORT. Retrying..."
      ((ATTEMPT++))
      PORT=$((PORT + 1))
    else
      echo "UE $i iPerf3 test complete."
      break
    fi
  done

  if [ $ATTEMPT -gt $RETRIES ]; then
    echo "$UE_NAME failed to connect after $RETRIES attempts." | tee -a $RESULTS_FILE
  fi
done

echo "===== All iPerf3 tests done. Results saved to $RESULTS_FILE ====="
