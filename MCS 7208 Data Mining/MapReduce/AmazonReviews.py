from mrjob.job import MRJob
import csv
import io
import logging

log = logging.getLogger(__name__)

def string_to_csv_line(s):
    # Create a string buffer to write CSV data
    output = io.StringIO()
    # Initialize CSV writer with minimal quoting
    writer = csv.writer(output, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)
    # Write the string as a single field in a row
    writer.writerow([s])
    # Return the CSV line, removing trailing newline characters
    return output.getvalue().rstrip('\r\n')

class AmazonReviews(MRJob):

    def mapper(self, _, line):
        # csv_line = string_to_csv_line(line)
        # log.info("---------------------------")
        # log.info(csv_line)
        # log.info("+++++++++++++++++++++++++++++")
        # log.info(line)

        # yield "good", len(csv_line)
        # for x in csv_line:
        #
        #     yield "loop", 1

        # if(len(line.split(',')) > 10):
        #     # print(len((line.split(',')[1])))
        #     yield "rating", (line.split(',')[9]).count("Good")
        #     yield "rating count", 1
        yield "lines", 1
        sentiment = 1 if 'good' in line.lower() else 0
        yield "sentiment", sentiment

    def reducer(self, key, values):
        yield key, sum(values)


if __name__ == '__main__':
    AmazonReviews.run()