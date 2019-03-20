extern void cls();
extern void getChar(); 
extern void printChar();
extern void printf();
extern void set();
extern void load();
extern void load2();
extern void jmp2();
extern void jmp();
extern void show_color_word(); /*show_color_word(char,x,y,color)*/

char welcome[]=" Welcome to the Operating System of Yezhan Pang and Sijie Peng.\n There are five user programs that you can load.\n";
char help[]=" You can input some legal instructions to make them work.\n If you need some information about them, please input \"help\".\n";
char devide[]=" ------------------------------------------------------------------------------\n";
char instruction1[]=" HELP:\n 1.Run by parallel, input \"run\" and the number of programs you want to run. \n Then they will run together.\n      For example: run 1 2 3 4\n";
char instruction2[]=" 2.Get INFORMATION of five programs, input \"show\". \n      For example: show\n";
char instruction3[]=" 3.Run the DEFAULT instructions, input \"def\". \n      For example: def\n";
char instruction4[]=" 4.Run the new system call test program, input \"test\". \n      For example: test\n";
char message_show1[]=" USER PROGRAM1:   Name:show1, Size:1024byte, Position:section 2\n";
char message_show2[]=" USER PROGRAM2:   Name:show2, Size:1024byte, Position:section 4\n";
char message_show3[]=" USER PROGRAM3:   Name:show3, Size:1024byte, Position:section 6\n";
char message_show4[]=" USER PROGRAM4:   Name:show4, Size:1024byte, Position:section 8\n";
char message_test[]=" USER PROGRAM5:    Name:test, Size:512byte, Postition:section 9\n";
char error_input[]=" INPUT ERROR!! Please input a legal instruction again. If you need some help, please input \"help\".\n";
char confirm[]=" Press any key to continue......\n";
char default_message[]=" OS will run instructions \"run 1 2 3 4\".\n";
const char default1[]="run 1 2 3 4";
char string[100];
char MYOS[]=" MYOS>";
int length=0,pos=0,x=0,y=0,i=0,a=0,u=0;
char ch;
int offset_user=41216;
const int offset_user1=41216;
const int offset_user2=42240;
const int offset_user3=43264;
const int offset_user4=44288;
const int segment_user[5]={0x800,0xA10,0xA50,0xA90,0xAd0};
int offset_begin=41216;
int offset_test2=45824;
int numofshanqu=8;
int firstshanqu=2;

typedef struct PCB
{
	int ax;
	int bx;
	int cx;
	int dx;
	int si;
	int di;
	int bp;
	int es;
	int ds;
	int ss;
	int sp;
	int ip;
	int cs;
	int flags;
	int status;
};
struct PCB PCBlist[5];
struct PCB *CurrentProc;

int pcb_num;
int current_pcb=0;
int time_cnt;
void init_pcb(int index,int segment,int offset)
{
	/*对第index个pcb进行初始化*/
	PCBlist[index].cs=segment;/*设置用户程序的段地址*/
	PCBlist[index].ip=offset;/*设置用户程序的偏移量*/
	PCBlist[index].flags=512;
	PCBlist[index].ss=segment;/*将用户程序栈段地址设置为用户程序段地址*/
	PCBlist[index].sp=0;/*设置用户程序栈的偏移量*/

}
/*汇编程序实现的进程调度函数，采用时间片轮转法。*/
/************************************************************************/
/*                    Scheduler 进程调度函数：时间片轮转       */                                                   
/************************************************************************/
void Scheduler()
{
	if(pcb_num)current_pcb++;
	if(current_pcb==pcb_num+1)current_pcb=1;

	/*中断一定次数后结束所有用户程序,返回内核*/
	/*规定0号pcb为内核pcb*/
	time_cnt--;
	if(time_cnt==0)current_pcb=0;
	CurrentProc=&PCBlist[current_pcb];
	return;
}

void run()
{
	cls();/*清屏*/
	numofshanqu=2;/*扇区数目*/
	pcb_num=0;
	for(i=0;i<5;i++)
		PCBlist[i].status=0;
	for(i=3;i<length;i++)
		if(string[i]>='1'&&string[i]<='4')PCBlist[(int)(string[i]-'0')].status=1;
	for(i=1;i<=4;i++)
		if(PCBlist[i].status==1)
		{
			load2(0,numofshanqu,i*2,segment_user[pcb_num+1]);
			init_pcb(pcb_num+1,segment_user[pcb_num+1],0);
			pcb_num++;
		}
	current_pcb=0;
	CurrentProc=&PCBlist[current_pcb];
	time_cnt=30*pcb_num;
	jmp2();
}

int int_i;
char even[20]="  is even.\0";
char odd[20]="  is odd.\0";
int number=0;
char num;
C_evenodd()
{
	num=number+'0';
	
	if(number%2==0)
	{	
		even[0]=num;
		for(int_i=0;even[int_i]!='\0';++int_i)
		show_color_char(even[int_i],11,34+int_i,4);	
	}
	else
	{	
		odd[0]=num;
		for(int_i=0;odd[int_i]!='\0';++int_i)
		show_color_char(odd[int_i],10,34+int_i,4);
	}
}

int sum=0;
int num1,num2;
char result[]=" + =  ";
C_sum()
{
	result[0]=num1+'0';
	result[2]=num2+'0';
	if(sum>=10)
	{	
		result[4]=sum/10+'0';
		result[5]=sum%10+'0';
		for(int_i=0;result[int_i]!='\0';++int_i)
		show_color_char(result[int_i],13,34+int_i,5);
	}
	else
	{
		result[4]=sum+'0';
		for(int_i=0;result[int_i]!='\0';++int_i)
		show_color_char(result[int_i],14,34+int_i,5);
	}
}

cal_pos()
{	
	if(y>79){
		y=0;
		x++;
	}
	if(x>24) cls();
	pos=(x*80+y)*2;
	set();
}

int input()
{
	getChar();
	if(ch=='\b'){
		if(y>6&&y<79){
			y--;
			cal_pos();
			printChar(' ');
			y--;
			cal_pos();
		}
		return 0;
	}
	else if(ch==13) ; 
	else printChar(ch);
	return 1;
}


MYOS_cin(){
	printf(MYOS);
	i=0;
	while(1)
	{
		if(input()){
			if(ch==13) break;
			string[i++]=ch;
		}
		else if(i>0) i--; 
	}
	for(a=0;a<i;++a)
		if(string[0]==' '){
			for(u=1;u<i;++u) string[u-1]=string[u];
			i--;
		}
		else break;
	string[i]='\0';
	length=i;
	printf("\n");
}

main(){
	while(1){
	cls();
	printf("\n");
	printf(devide);
	printf(welcome);
	printf(help);
	printf(devide);
	MYOS_cin();
	if((string[0]=='h'||string[0]=='H')&&(string[1]=='e'||string[1]=='E')
	&&(string[2]=='l'||string[2]=='L')&&(string[3]=='p'||string[3]=='P'))
	{
		printf(instruction1);
		printf(instruction2);
		printf(instruction3);
		printf(instruction4);
		printf(devide);
		printf(confirm);
		MYOS_cin();
	} 
	else if((string[0]=='r'||string[0]=='R')&&(string[1]=='u'||string[1]=='U')
	&&(string[2]=='n'||string[2]=='N'))  
	{
		run();
	}
	else if((string[0]=='s'||string[0]=='S')&&(string[1]=='h'||string[1]=='H')
	&&(string[2]=='o'||string[2]=='O')&&(string[3]=='w'||string[3]=='W')) 
	{
		printf(message_show1);
		printf(message_show2);
		printf(message_show3);
		printf(message_show4);
		printf(message_test);
		printf(devide);
		printf(confirm);
		MYOS_cin();
		
	}
	else if((string[0]=='d'||string[0]=='D')&&(string[1]=='e'||string[1]=='E')&&(string[2]=='f'||string[2]=='F'))
	{
		printf(default_message);
		printf(confirm);
		MYOS_cin();
		for(i=0;i<20;++i){
			string[i]=default1[i];
			if(default1[i]=='\0'){length=i;break;}
		}
		run();
	}

	else if((string[0]=='t'||string[0]=='T')&&(string[1]=='E'||string[1]=='e')&&(string[2]=='S'||string[2]=='s')&&(string[3]=='t'||string[3]=='T')) 		
	{	
		cls();
		/*offset_begin=offset_test1;/*内存偏移量*/
		numofshanqu=1;/*扇区数目*/
		firstshanqu=10;/*起始扇区号*/
		load(offset_test2,numofshanqu,firstshanqu);/*装载用户程序到内存*/
		offset_user=offset_test2;
		jmp();
	}
	else{
		printf(error_input);
		printf(devide);
		printf(confirm);		
		MYOS_cin();
	}
	}
}
