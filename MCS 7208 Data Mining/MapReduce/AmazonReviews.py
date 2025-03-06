from mrjob.job import MRJob


class AmazonReviews(MRJob):

    def mapper(self, _, line):

        yield "chars", len(line)
        if(len(line.split(',')) > 10):
            # print(len((line.split(',')[1])))
            yield "rating", (line.split(',')[9]).count("Good")
            yield "rating count", 1
        yield "lines", 1

    def reducer(self, key, values):
        yield key, sum(values)


if __name__ == '__main__':
    AmazonReviews.run()