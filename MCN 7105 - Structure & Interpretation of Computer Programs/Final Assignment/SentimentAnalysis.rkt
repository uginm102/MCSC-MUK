;Eugene Munyaneza
;MCN 7105 Final Assignment
;Student name: 2400721936
;Reg. No. 2024/HD05/21936U
;Programme  MCSC

#lang racket

;;; Import required libraries
(require data-science)                 ; For sentiment analysis
(require plot)                         ; For visualization
(require racket/string)                ; For text manipulation

;;; 1. Read Tweets from CSV File
(define (read-tweets file-path)
  (map (lambda (row) (list (first row) (second row) (third row)))
       (cdr (read-csv file-path))))  ; Skip header row

(define tweet-data (read-tweets "tweets.csv"))

;;; 2. Filter Tweets by Location
(define (filter-tweets-by-location tweets location)
  (filter (lambda (row)
            (and (string? (third row))
                ; (string-ci=? (third row) location)))
                ; (string-ci-contains? (string-trim (third row)) location)))  ; Check for "Canada"
                  (regexp-match? (regexp (string-downcase location))          ; Match lowercase location
                               (string-downcase (string-trim (third row)))))) ; Lowercase and trim
          tweets))

;;; You can change this to the country you want to investigate.
(define country "Canada")

(define country-tweets (filter-tweets-by-location tweet-data country))

(printf "Number of filtered tweets: ~a\n" (length country-tweets))


(if (empty? country-tweets)
    (printf "No tweets found for the specified location.\n")
    (begin
      (printf "Filtered Tweets: ~a\n" (length country-tweets))))

;;; 3. Extract and Normalize the 'text' Column
(define tweet-texts (map second tweet-data))  ; Extract the 'text' column

(if (empty? tweet-texts)
    (printf "No tweet texts available for processing.\n")
    (printf "Tweet texts: ~a\n" (length tweet-texts )))

(define normalized-texts
  (map (lambda (text)
         (string-normalize-spaces (remove-punctuation (string-downcase text))))
       tweet-texts))

;;; Tokenize and Prepare Tokens for Sentiment Analysis
(define raw-tokens
  (apply append (map (lambda (text) (document->tokens text #:sort? #t)) normalized-texts)))

;;; Format tokens for sentiment analysis
(define formatted-tokens
  (filter
   pair?
   (map (lambda (pair)
          (if (pair? pair)
              pair  ; Keep valid pairs as is
              (list pair "dummy")))  ; Add dummy metadata for single tokens
        raw-tokens)))

(if (empty? formatted-tokens)
    (printf "No tokens extracted from tweets.\n")
    (printf "Formatted Tokens: ~a\n" (take formatted-tokens 10)))

;;; 4. Perform Sentiment Analysis
(define raw-sentiment
  (list->sentiment formatted-tokens #:lexicon 'nrc))  ; Pass the properly formatted token list
;;;;;;;;;;;;;;;;;;;;;;;;
;;; Remove Header or Invalid Entries
(define sentiment
  (filter (lambda (entry)
            (and (list? entry)                     ; Ensure it's a list
                 (>= (length entry) 3)             ; Ensure at least 3 elements
                 (string? (list-ref entry 0))      ; First element is a string
                 (string? (list-ref entry 1))      ; Second element is a string
                 (number? (list-ref entry 2))))    ; Third element is a number
          raw-sentiment))
;;;;;;;;;;;;;;;;;;;;;;;;
(if (empty? sentiment)
    (printf "No sentiment data available.\n")
    ;(printf "Sentiment: ~a\n" sentiment) ;The whole dataset
    (printf "Sentiment: ~a\n" (take sentiment 5)))

;;; 5. Aggregate Sentiment Labels
(define (aggregate-sentiment sentiment-data)
  "Aggregates sentiment counts into a list of (label count) pairs."
  ;; Filter valid entries from sentiment-data
  (define valid-sentiments
    (filter
     (lambda (entry)
       (and (list? entry)                 ; Ensure it's a list
            (>= (length entry) 3)         ; Ensure it has at least 3 elements
            (string? (list-ref entry 1))  ; 'sentiment' is a string
            (number? (list-ref entry 2)))) ; 'freq' is a number
     sentiment-data))
  
  ;; Debugging: Print invalid entries if any
  (define invalid-sentiments
    (filter (lambda (entry) (not (member entry valid-sentiments))) sentiment-data))
  (when (not (empty? invalid-sentiments))
    (printf "Warning: Found invalid sentiment entries: ~a\n" invalid-sentiments))

  ;; Aggregate valid sentiments using a mutable hash
  (define sentiment-groups (make-hash))  ; Create a mutable hash table
  (for ([entry valid-sentiments])
    (define label (list-ref entry 1))    ; Access 'sentiment'
    (define freq (list-ref entry 2))     ; Access 'freq'
    (hash-set! sentiment-groups
               label
               (+ (hash-ref sentiment-groups label 0) freq)))  ; Increment frequency
  
  ;; Convert hash to list of (label count) pairs
  (for/list ([key (in-hash-keys sentiment-groups)])
    (list key (hash-ref sentiment-groups key))))


(define sentiment-aggregation (aggregate-sentiment sentiment))

;;; 6. Visualize Sentiment Distribution
(define (plot-sentiment-distribution sentiment-data)
  "Plots the sentiment distribution as a barplot."
  (if (empty? sentiment-data)
      (printf "No sentiment data available for plotting.\n")
      (parameterize ((plot-width 800))
        (plot (list
               (tick-grid)
               (discrete-histogram
                (sort sentiment-data (lambda (x y) (> (second x) (second y))))
                #:color "MediumSlateBlue"
                #:line-color "MediumSlateBlue"))
              #:x-label "Sentiment"
              #:y-label "Frequency"
              #:title "Sentiment Distribution for Canada"))))

(plot-sentiment-distribution sentiment-aggregation)
