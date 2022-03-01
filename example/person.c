#include <stdio.h>
#include <stdlib.h>
#include "person.pb-c.h"

int main() {
	Person *person = malloc(sizeof(Person));
	person->id = "54321";
	person->name = "Juergen";
	printf("%s %s\n", person->id, person->name);
	return 0;
}
