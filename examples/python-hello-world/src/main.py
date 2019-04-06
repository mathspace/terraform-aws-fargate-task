import logging
import os


# Setup logging in order for CloudWatch Logs to work properly
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


if __name__ == "__main__":
    logger.info(f"Hello world - this is {os.environ['FROM_NAME']}")
