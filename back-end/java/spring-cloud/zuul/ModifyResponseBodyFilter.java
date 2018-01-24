// https://github.com/spring-cloud-samples/sample-zuul-filters/blob/master/src/main/java/org/springframework/cloud/samplezuulfilters/ModifyResponseBodyFilter.java

	public Object run() {
		try {
			RequestContext context = getCurrentContext();
			InputStream stream = context.getResponseDataStream();
			String body = StreamUtils.copyToString(stream, Charset.forName("UTF-8"));
			context.setResponseBody("Modified via setResponseBody(): "+body);
		}
		catch (IOException e) {
			rethrowRuntimeException(e);
		}
		return null;
	}