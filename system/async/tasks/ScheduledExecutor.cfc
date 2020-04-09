/**
 * This is the ColdBox Executor class which connects your code to the Java
 * Scheduling services to execute tasks on.
 *
 * The native property models the injected Java executor which can be:
 * - Fixed
 * - Cached
 * - Single
 * - Scheduled
 */
component extends="Executor" accessors="true" singleton{

	/**
	 * This method is used to register a runnable CFC, closure or lambda so it can
	 * execute as a scheduled task according to the delay and period you have set
	 * in the Schedule.
	 *
	 * The method will register the runnable and send it for execution, the result
	 * is a ScheduledFuture.  Periodic tasks do NOT return a result, while normal delayed
	 * tasks can.
	 *
	 * @task The runnable task closure/lambda/cfc
	 * @delay The time to delay the first execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @throws RejectedExecutionException - if the task cannot be scheduled for execution
	 *
	 * @return ScheduledFuture representing pending completion of the task and whose get() method will return null upon completion
	 */
	ScheduledFuture function schedule(
		required task,
		numeric delay=0,
		timeUnit="seconds",
		method = "run"
	){
		// build out the java callable
		var jCallable = createDynamicProxy(
			new coldbox.system.async.proxies.Callable(
				arguments.task,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.concurrent.Callable" ]
		);

		// Schedule it in the executor
		var jScheduledFuture = variables.native.schedule(
			jCallable,
			javacast( "long", arguments.delay ),
			this.$timeUnit.get( arguments.timeUnit )
		);

		// Return the results
		return new ScheduledFuture( jScheduledFuture );
	}

	/**
	 * Creates and executes a periodic action that becomes enabled first after
	 * the given initial delay, and subsequently with the given period;
	 * that is executions will commence after delay then delay+every, then delay + 2 * every,
	 * and so on.
	 *
	 * If any execution of the task encounters an exception, subsequent executions are
	 * suppressed. Otherwise, the task will only terminate via cancellation or termination
	 * of the executor. If any execution of this task takes longer than its period,
	 * then subsequent executions may start late, but will not concurrently execute.
	 *
	 * @task The runnable task closure/lambda/cfc
	 * @every The period between successive executions
	 * @delay The time to delay the first execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @throws RejectedExecutionException - if the task cannot be scheduled for execution
	 * @throws IllegalArgumentException - if period less than or equal to zero
	 *
	 * @return a ScheduledFuture representing pending completion of the task, and whose get() method will throw an exception upon cancellation
	 */
	ScheduledFuture function scheduleAtFixedRate(
		required task,
		required numeric every,
		numeric delay=0,
		timeUnit="seconds",
		method = "run"
	){
		// Schedule it
		var jScheduledFuture = variables.native.scheduleAtFixedRate(
			buildJavaRunnable( argumentCollection=arguments ),
			javacast( "long", arguments.delay ),
			javacast( "long", arguments.every ),
			this.$timeUnit.get( arguments.timeUnit )
		);

		// Return the results
		return new ScheduledFuture( jScheduledFuture );
	}

	/**
	 * Creates and executes a periodic action that becomes enabled first after the given
	 * delay, and subsequently with the given spacedDelay between the termination of one
	 * execution and the commencement of the next.
	 *
	 * If any execution of the task encounters an exception, subsequent executions are
	 * suppressed. Otherwise, the task will only terminate via cancellation or
	 * termination of the executor.
	 *
	 * @task The runnable task closure/lambda/cfc
	 * @spacedDelay The delay between the termination of one execution and the commencement of the next
	 * @delay The time to delay the first execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @throws RejectedExecutionException - if the task cannot be scheduled for execution
	 * @throws IllegalArgumentException - if spacedDelay less than or equal to zero
	 *
	 * @return a ScheduledFuture representing pending completion of the task, and whose get() method will throw an exception upon cancellation
	 */
	ScheduledFuture function scheduleWithFixedDelay(
		required task,
		required numeric spacedDelay,
		numeric delay=0,
		timeUnit="seconds",
		method = "run"
	){
		// Schedule it
		var jScheduledFuture = variables.native.scheduleWithFixedDelay(
			buildJavaRunnable( argumentCollection=arguments ),
			javacast( "long", arguments.delay ),
			javacast( "long", arguments.spacedDelay ),
			this.$timeUnit.get( arguments.timeUnit )
		);

		// Return the results
		return new ScheduledFuture( jScheduledFuture );
	}

	/****************************************************************
	 * Private Methods *
	 ****************************************************************/

	/**
	 * Build out a Java Runnable from the incoming cfc/closure/lambda/udf
	 *
	 * @task The runnable task closure/lambda/cfc
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return A java.lang.Runnable
	 */
	function buildJavaRunnable( required task, required method ){
		return createDynamicProxy(
			new coldbox.system.async.proxies.Runnable(
				arguments.task,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.lang.Runnable" ]
		);
	}

}