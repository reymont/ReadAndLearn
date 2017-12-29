

# https://github.com/reymont/fluentd2kibana



```yml
{
	searchSourceJSON: {
		index: AWB8YHeaWrkYh5m47SqW,
		highlightAll: true,
		version: true,
		query: {
			match_all: {}
		},
		filter: [{
				$state: {
					store: appState
				},
				meta: {
					alias: 172.20.62.105,
					disabled: false,
					index: AWB8YHeaWrkYh5m47SqW,
					key: hostname,
					negate: false,
					type: phrase,
					value: 172.20.62.105
				},
				query: {
					match: {
						hostname: {
							query: 172.20.62.105,
							type: phrase
						}
					}
				}
			}, {
				meta: {
					index: AWB8YHeaWrkYh5m47SqW,
					negate: false,
					disabled: true,
					alias: business - adapter,
					type: phrase,
					key: micro_service,
					value: business - adapter
				},
				query: {
					match: {
						micro_service: {
							query: business - adapter,
							type: phrase
						}
					}
				},
				$state: {
					store: appState
				}
			}, {
				meta: {
					index: AWB8YHeaWrkYh5m47SqW,
					negate: false,
					disabled: true,
					alias: boss - callback,
					type: phrase,
					key: micro_service,
					value: boss - callback
				},
				query: {
					match: {
						micro_service: {
							query: boss - callback,
							type: phrase
						}
					}
				},
				$state: {
					store: appState
				}
			}, {
				meta: {
					index: AWB8YHeaWrkYh5m47SqW,
					negate: false,
					disabled: true,
					alias: business - lifeservice,
					type: phrase,
					key: micro_service,
					value: business - lifeservice
				},
				query: {
					match: {
						micro_service: {
							query: business - lifeservice,
							type: phrase
						}
					}
				},
				$state: {
					store: appState
				}
			}
		]
	}
}
```