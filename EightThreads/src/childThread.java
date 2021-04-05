import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.*;

/* Eight Threads, Shared Data, Using Locks
 * childThread
 * CS 485
 * Jason Bendickson
 */
public class childThread extends Thread{
	
	//variables
	volatile boolean run = true;	
	private ThreadData threadData;
	private Thread t = null;
	private AtomicInteger sharedCounter;
	private Lock lock = new ReentrantLock();

	
	childThread( ThreadData threadData, AtomicInteger sharedCounter){
		this.threadData = threadData;
		this.sharedCounter = sharedCounter;
	}
	
	public void sharedCounterLock() {					//get lock, increment shared Counter, release lock
		lock.lock(); 
		try {
			sharedCounter.getAndIncrement();
		}
		finally {
			lock.unlock();
		}
	}	
	
	public void run() {
		System.out.println(Thread.currentThread().getName() + " has started.");
		while(run) {
			//Track increments of counter
			for(int i = 0; i<100; i++) {
				try {
					threadData.tdCounter();					//lock, Increment, unlock
					sharedCounterLock(); 							//increment sharedCounter
			
					//Sleep every 100 increments
					if(i==99) {
						i++;
						try {
							Thread.sleep(50);
						} 
						catch(InterruptedException e) {
							e.printStackTrace();
						}
					}
				}catch(Exception ex) {
					ex.printStackTrace();
				}

			}
			//end once counter has reached desired value
			if(threadData.getCount()>=10000) {
				System.out.println(Thread.currentThread().getName() + " has completed incrementing up to 10000.");
				break;
			
			}
		}
	}

}