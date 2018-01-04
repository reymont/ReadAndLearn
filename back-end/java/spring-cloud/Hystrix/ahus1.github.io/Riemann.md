

# https://ahus1.github.io/hystrix-examples/manual.html#_real_time_monitoring_of_hystrix_metrics

15. Real time monitoring of Hystrix metrics
15.1. Riemann as cutting edge realtime event processing
Riemann is a a modern event management system. It has been designed with with performance in mind for montoring complex systems. To process the data fast it keeps the last few minutes of data in memory. All events are processed in a streaming mode.

The events can be aggregated and filtered. You can also start actions like notifying IT operations of problems.

Riemann comes with its own dashboard that can show you can use to show real time graphs and statistics.

So far both the Hystrix Dashboard and Zabbix have been presented. You could consider Riemann for the following:

Zabbix polls existing metrics from Hystrix. You can aggregate events to deliver your own metrics using Riemann. This all happens outside of the application. This gives you a lot of flexibility.

While the Hystrix Dashboard is a great start for a dashboard, it is not configurable. The Riemann Dashboard is highly configurable (once you understand its keyboard shortcuts) and might delivery you additional insights you might need to administer your cluster.

Assuming that Zabbix receives information every minute, this means that you will receive alerts with a delay of one minute. After a problem disappeared (for example after you have restarted a service, or fixed a configuration problem) you will see this only after a minute or two in the Zabbix graphs. Riemann gives you the options to be notified immediately by a channel of your choice (email, SMS, chat) when the problem occurs and when it is fixed.

Filtered events can be forwarded to systems like InfluxDB to be stored. These can be displayed later using tools like Grafana. But lets start with Riemann first.

15.2. Installing and running Riemann
The installation has been scripted as a Vagrant script. This will first download a linux image of CentOS and spin it up in Virtualbox. Then it will hand over to a provisioner, in our case this is Saltstack.

To install Vagrant please see Running virtual machines for test and development. Once it is installed, run the follwing command in tools/riemann:

vagrant up
This will take a while to download all the files necessary. Once it is up and running point your browser at your local Riemann installation: http://localhost:4567/.

15.3. How Events are captures for Riemann
In the example application the HystrixSetupListener registers the class HystrixRiemannEventNotifier with Hystrix. This will be notified with the detailed timinings of each run command and with the outcome of each command (successful, timeout, etc.).

These events are queued in a bounded queue. The result will be forwarded to Riemann in batches every 100 ms.

In order to activate the forwarding of events, you’ll need to change hystrixdemo.enableriemann to true in archaius.properties. This change will be active immediately.

15.4. Configuring Riemann Server
In this setup the information about Hystrix commands is forwarded on a level of a single command execution.

We can present it on this level, but usually you want to create aggreation on top of the event stream. The first listing aggregates the timings of the service IBANValidatorCommand.

Percentiles with riemann.config
(let [index (index)]
  (streams
    (where (and (= service "IBANValidatorCommand") (not (= metric nil)) )

       ; Now, we'll calculate the 50th, 95th, and 99th percentile for all
       ; requests in each 5-second interval.

       (percentiles 5 [0.5 0.95 0.99]

           ; Percentiles will emit events like
           ; {:service "api req 0.5" :metric 0.12}
                   ; We'll add them to the index, so they can show up
           ; on our dashboard.

           index)
    )
  )
)
The second listing counts the different outcomes (SUCCESS, TIMEOUT, etc.) in every five second interval. This statement contains a statement for logging the aggregated events in the Riemann server log.

Counting with riemann.config
(let [index (index)]
  (streams
    (where (and (= service "IBANValidatorCommand") (= metric nil) )

      (by :state
        (with :metric 1 (with :service "IBAN Count"
          (rate 5
          ; log all events (for debugging)
          #(info "received event" %)
            index
          )
        ))
      )

    )
  )
)
15.5. Configuring Riemann Dashboard
You can configure the frontend of Riemann in your browser. This setup installs a dashboard that shows some useful information about the example application.

Riemann Dashboard
Figure 9. Riemann Dashboard
In the lower part of the screen you will see a guide how to use keyboard shortcuts to customize the dashboard.

As with the Zabbix monitoring, this will only show useful information once some commands are run. Please use the JMeter load test for this.