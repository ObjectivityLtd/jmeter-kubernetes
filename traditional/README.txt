1. Checkout repo
2. Install jmeter: ./install_jmeter.sh apache-jmeter-5.2.1
3. Install python requirements: pip install -r requirements.txt
4. Start controller in the background

   ./jmeter_controller.py &

Run pipeline:

    azure-pipelines.0.private.agent.maven.distributed.traditional.yml