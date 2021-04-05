/* Eight Threads, Shared Data, Using Locks
 * mainThread
 * CS 485
 * Jason Bendickson
 */
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
public class mainThread {
	
	private static AtomicInteger sharedCounter;

	public static void main(String[] args) throws InterruptedException {

		//create atomic integer to count all increments
		sharedCounter = new AtomicInteger(0);
		
		ThreadData thread1Data = new ThreadData("Thread_1");
		ThreadData thread2Data = new ThreadData("Thread_2");
		ThreadData thread3Data = new ThreadData("Thread_3");
		ThreadData thread4Data = new ThreadData("Thread_4");
		ThreadData thread5Data = new ThreadData("Thread_5");
		ThreadData thread6Data = new ThreadData("Thread_6");
		ThreadData thread7Data = new ThreadData("Thread_7");
		ThreadData thread8Data = new ThreadData("Thread_8");
		//set counter start value
		sharedCounter = new AtomicInteger(0);
		//create child threads
		childThread thread1 = new childThread(thread1Data, sharedCounter);
		Thread t1 = new Thread(thread1, "Thread_1");		
		
		childThread thread2 = new childThread(thread2Data, sharedCounter);
		Thread t2 = new Thread(thread2, "Thread_2");		
		
		childThread thread3 = new childThread(thread3Data, sharedCounter);
		Thread t3 = new Thread(thread3, "Thread_3");		
		
		childThread thread4 = new childThread(thread4Data, sharedCounter);
		Thread t4 = new Thread(thread4, "Thread_4");
		
		childThread thread5 = new childThread(thread5Data, sharedCounter);
		Thread t5 = new Thread(thread5, "Thread_5");		
		
		childThread thread6 = new childThread(thread6Data, sharedCounter);
		Thread t6 = new Thread(thread6, "Thread_6");		
		
		childThread thread7 = new childThread(thread7Data, sharedCounter);
		Thread t7 = new Thread(thread7, "Thread_7");		
		
		childThread thread8 = new childThread(thread8Data, sharedCounter);
		Thread t8 = new Thread(thread8, "Thread_8");
		
		//start child threads
		t1.start();
		t2.start();
		t3.start();
		t4.start();
		t5.start();
		t6.start();
		t7.start();
		t8.start();
		
		
		System.out.println("Active Threads: " + Thread.activeCount());
		
		//check progress every 1/2 second
		for (int i = 1; i < 100; i++) {
			try {Thread.sleep(500);}
			catch(InterruptedException e) {}
			
			System.out.println("Initial Thread Shared Counter Value = " + sharedCounter);
			if(i == 100) {System.out.println("The Program has Failed.");}
			if(sharedCounter.get()>=80000) {
				System.out.println("Initial Thread is Complete.");				
				break;
			}//end if
			
		}//end for loop


	}//end main

}//end class