

# https://www.infoq.com/articles/spring-cloud-service-wiring

Enabling Dynamic Refresh

With the configuration stored in a centralised place we have an easy way to change the repmax configuration in a way that is visible to all services. However, picking up those configurations still requires a restart. We can do better. Spring Boot provides the @ConfigurationProperties annotation that allows us to map configuration directly on to JavaBeans. Spring Cloud Config goes a step further, and exposes a /refresh endpoint in every client service. Beans that are annotated with @ConfigurationProperties have their properties updated whenever a refresh is triggered through the /refresh endpoint.

Any bean can be annotated with @ConfigurationProperties, but it makes sense to restrict refresh support to just the beans that contain configuration data. To this end, we extract a LeaderboardConfig bean that serves as a holder for the leaderboard address:

@ConfigurationProperties("leaderboard.lb")
public class LeaderboardConfig {

    private volatile String url;

    public String getUrl() {
        return this.url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
The value of the @ConfigurationProperties annotation is the prefix for configuration values we want to map into our bean. Then, each value is mapped using standard JavaBean naming conventions. In this case, the url bean property is mapped to leaderboard.lb.url in the configuration.

We then modify ConfigurableLeaderBoardApi to accept an instance of LeaderboardConfig rather than the raw leaderboard address:

public class ConfigurableLeaderBoardApi extends AbstractLeaderBoardApi {

    private final LeaderboardConfig config;

    @Autowired
    public ConfigurableLeaderBoardApi(LeaderboardConfig config) {
        this.config = config;
    }

    @Override
    protected String getLeaderBoardAddress() {
        return this.config.getLeaderboardAddress();
    }
}
To trigger a config refresh, send an HTTP POST request to the /refresh endpoint of the logbook service:

curl -X POST http://localhost:8081/refresh